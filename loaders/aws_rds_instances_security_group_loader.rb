# nodes == rds instances or CIDR addresses (or security groups outside the account )
# edges == permissions between instances/addresses/external-security-groups as defined by the assigned security groups
# clusters == vpc/internet/classic/external-account: location/owner of the instance/cidr/external-security-group

class AwsRdsInstancesSecurityGroupLoader < AwsSecurityGroupLoader

  def instance_name(i)
    i.tags.select { |t| t.key == 'Name'}.first&.value || i.id
  end

  def load_groups
    insts = @rds.db_instances
    ## build a sg-id -> sg lookup table
    sg_map = @ec2.security_groups.inject({}) {|h, sg| h[sg.id]=sg; h }

    ## build group_id -> [instances] map
    # initialize a hash of all groups with empty sets as values
    instance_groups = Hash[sg_map.keys.map { |s| [s, Set.new] }]
    insts.each do |i|
      i.vpc_security_groups.each do |sg_struct|
        gid = sg_struct['vpc_security_group_id']
        if instance_groups[gid].nil?
          raise "ERROR: Security group '#{gid}' on instances '#{i.id}' doesn't seem to exist in the list of all valid EC2 security groups."
        end
        instance_groups[gid].add(i)
      end
    end


    # Take an instance, add it as a node, go through each perm in each group,
    # and add an edge between that instance and the instances that have the source perm.
    # Append the sec-group to the edge's metadata so we know where the permission came from
    puts insts
    insts.each do |i|
      cluster_id = i.vpc_id || 'classic'
      dst_node = add_inst_node(i.id, instance_name(i), cluster_id, 'rds', i)
      dst_node.owner_id = ''

      sgs = i.vpc_security_groups.map { |g| sg_map[g['vpc_security_group_id']] }

      sgs.each do |sg|
        sg.ip_permissions.each do |p|
          src_port = p.from_port || '0'
          dst_port = p.to_port || '65535'
          protocol = p.ip_protocol == '-1' ? 'all' : p.ip_protocol
          edge_props = {
            protocol: protocol,
            port_start: src_port,
            port_end: dst_port,
            owner_id: ''
          }
          # Different logic for CIDRs vs AWS groups since they have different structures

          # If permission from a CIDR...
          if p.user_id_group_pairs.empty?
            src_node_uid = p.ip_ranges.first.cidr_ip
            src_node_name = src_node_uid
            src_node = add_inst_node(src_node_uid, src_node_name, 'internet', 'cidr')
            e = add_inst_edge(src_node, dst_node, edge_props, sg)
            next
          end

          # If permission from an AWS group that we don't own...
          if instance_groups[p.user_id_group_pairs.first.group_id].nil?
            if p.user_id_group_pairs.first.peering_status == 'deleted'
              puts "WARNING: Outdated permission found in group '#{dst_node.name}' (#{dst_node.uid}) to group #{p.user_id_group_pairs.first.group_id} in vpc '#{p.user_id_group_pairs.first.vpc_id}'. Peering has been deleted."
              next
            end
            # groups can be owned by others (ex. elbs, rds, etc) in which case we can't look up our instances assigned to that group
            src_node_owner_id = p.user_id_group_pairs.first.user_id
            src_node_id = p.user_id_group_pairs.first.group_id
            src_node_uid = src_node_owner_id + '/' + src_node_id
            src_node_name = src_node_owner_id + '/' + ( p.user_id_group_pairs.first.group_name || src_node_id )
            cluster_id = "account-#{src_node_owner_id}"
            src_node = add_inst_node(src_node_uid, src_node_name, cluster_id, 'external-security-group')
            add_inst_edge(src_node, dst_node, edge_props, sg)
            next
          end

          # If permission from an AWS group that we own, create connections to each instance that has that group assigned
          instance_groups[p.user_id_group_pairs.first.group_id].each do |src_inst|
            src_node_uid = src_inst.id
            src_node_name = instance_name(src_inst)
            cluster_id = src_inst.vpc_id || 'classic'
            src_node = add_inst_node(src_node_uid, src_node_name, cluster_id, 'instance')
            # src_node = add_inst_node(src_node_uid, src_node_name, cluster_id, src_inst.type)
            add_inst_edge(src_node, dst_node, edge_props, sg)
          end
        end
      end
    end
    [@nodes, @edges, @clusters]
  end

  private

  def add_inst_edge(tail_node, head_node, edge_props, edge_data_source)
    add_sg_edge(tail_node, head_node, edge_props, edge_data_source, Ec2SecurityGroupInstanceEdge)
  end

  def add_inst_node(uid, name, cluster_id, type, inst=nil)
    add_sg_node(uid, name, cluster_id, type)
  end


end
