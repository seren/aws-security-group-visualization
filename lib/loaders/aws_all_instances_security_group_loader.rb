# nodes == ec2/rds/elb instances, CIDR addresses, or security groups outside the account
# edges == permissions between instances/addresses/external-security-groups as defined by the assigned security groups
# clusters == vpc/internet/classic/external-account: location/owner of the instance/cidr/external-security-group

require_relative 'aws_input_normalization/aws_instance.rb'
require_relative 'aws_input_normalization/cidr_instance.rb'
require_relative 'aws_input_normalization/ec2_instance.rb'
require_relative 'aws_input_normalization/elb_instance.rb'
require_relative 'aws_input_normalization/rds_instance.rb'
require_relative 'aws_input_normalization/external_instance.rb'


class AwsAllInstancesSecurityGroupLoader < AwsSecurityGroupLoader

  def load_groups
    current_account_id = "acct" + @sts.get_caller_identity.account

    ## build an sg-id -> sg lookup table
    sg_map = @ec2.security_groups.inject({}) {|h, sg| h[sg.id]=sg; h }

    # Gather AWS entity info from multiple sources
    insts = @ec2.instances.map { |i| Ec2Instance.new(i, sg_map, current_account_id) }
    insts += @rds.db_instances.map { |i| RdsInstance.new(i, sg_map, current_account_id) }  # Note, names are not guarenteed to be unique across accounts
    # Get classic ELBs
    insts += @elb1.describe_load_balancers['load_balancer_descriptions'].map { |i| ElbInstance.new(i, sg_map, current_account_id) }  # Note, names are not guarenteed to be unique across accounts
    # Get application and network LBs
    insts += @elb2.describe_load_balancers['load_balancers'].map { |i| ElbInstance.new(i, sg_map, current_account_id) }  # Note, names are not guarenteed to be unique across accounts

    ## build an instance uid -> aws instance lookup table
    insts_map = insts.inject ({}) { |acc, i| acc[i.uid] = i; acc }

    ## build an sg_id -> [instances] lookup table
    # initialize a hash of all groups with empty sets as values
    instance_sgs = Hash[sg_map.keys.map { |s| [s, Set.new] }]
    insts.each do |i|
      i.security_groups.keys.each do |gid|
        if instance_sgs[gid].nil?
          raise "ERROR: Security group '#{gid}' on instances '#{i.id}' doesn't seem to exist in the list of all valid EC2 security groups."
        end
        instance_sgs[gid].add(i)
      end
    end

    # Create all of the nodes from the list of aws instances
    insts.each do |i|
      i.node = add_inst_node(i)
      i.node.owner_id = ''
    end

    puts "DONE creating initial nodes"

    # For each permission on each security group on each instance,
    # add an edge between that instance and the instances that have the source perm.
    # Append the sec-group to the edge's metadata so we know where the permission came from
    insts.each do |i|
      i.security_groups.values.each do |sg|
        sg.ip_permissions.each do |p|

          dst_node = i.node

          edge_props = {
            protocol: p.ip_protocol == '-1' ? 'all' : p.ip_protocol,
            port_start: p.from_port || '0',
            port_end: p.to_port || '65535',
            owner: ''
          }

          # Different logic for CIDRs vs AWS groups since they have different structures

          if p.user_id_group_pairs.empty?
            # If permission from a CIDR...
            p.ip_ranges.each do |cidr|
              src_i = CidrInstance.new(p, cidr)
              src_node = add_inst_node(src_i)
              e = add_inst_edge(src_node, dst_node, edge_props, sg)
            end
            next

          else
            # Permission is from a named-group
            p.user_id_group_pairs.each do |group|

              # If permission from an AWS group that we don't own...
              if instance_sgs[group.group_id].nil?
                if group.peering_status == 'deleted'
                  puts "WARNING: Outdated permission found in group '#{dst_node.name}' (#{dst_node.uid}) to group #{group.group_id} in vpc '#{group.vpc_id}'. Peering has been deleted."
                  next
                end
                # groups can be owned by others (ex. elbs, rds, etc) in which case we can't look up our instances assigned to that group
                src_i = ExternalInstance.new(p, group)
                src_node = add_inst_node(src_i, 'external-security-group')
                add_inst_edge(src_node, dst_node, edge_props, sg)
                next
              end

              # If permission from an AWS group that we own, create connections to each instance that has that group assigned
              instance_sgs[group.group_id].each do |src_i|
                src_node = add_inst_node(src_i,  insts_map[src_i.uid].type)
                add_inst_edge(src_node, dst_node, edge_props, sg)
              end
            end
          end

        end
      end
    end
    # binding.pry
    [@nodes, @edges]
  end

  private

  def add_inst_edge(tail_node, head_node, edge_props, edge_data_source)
    add_sg_edge(tail_node, head_node, edge_props, edge_data_source, Ec2SecurityGroupInstanceEdge)
  end

  def add_inst_node(inst, type=inst.type)
    puts ""
    add_sg_node(type + '_' + inst.uid, inst.name, inst.vpc_id, type)
  end


end
