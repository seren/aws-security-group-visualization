# tail = src
# head = dst

# nodes == ec2 security groups or CIDR addresses
# edges == permissions between groups/addresses
# clusters == vpcs/ec2-classic/external-accounts/internet: location/owner of the security-group/cidr

class AwsSecurityGroupLoader < Loader

  def initialize(args = {})
    @vpc_name_cache = nil
    super
  end

  def connect_to_aws(args)
    if args[:profile]
      credentials = Aws::SharedCredentials.new(profile_name: args[:profile])
      Aws.config.update(credentials: credentials)
    else
      Aws.config.update(access_key_id: args[:aws_access_key_id], secret_access_key: args[:aws_secret_access_key])
    end
    @ec2 = Aws::EC2::Resource.new(region: args[:region])
    @elb1 = Aws::ElasticLoadBalancing::Client.new(region: args[:region])
    @elb2 = Aws::ElasticLoadBalancingV2::Client.new(region: args[:region])
    @rds = Aws::RDS::Resource.new(region: args[:region])
    @sts = Aws::STS::Client.new(region: args[:region])
  end


  def load_groups
    # Build a group_id -> group map so we can do lookups easily
    groups = {}
    @ec2.security_groups.each { |g| groups[g.id] = g }

    groups.values.each do |g|
      puts "Group: #{g.to_s}"
      g.ip_permissions.each do |p|
        # need different logic for cidrs vs named groups, since cidrs will create multiple destination nodes
        # if cidr,
        puts "IP Permission: #{p.to_s}"
        puts "dst_node g: #{g}"
        dst_node = add_sg_node(g.group_id, g.group_name, g.vpc_id || 'classic', 'security-group')
        dst_node.owner_id = g.owner_id

        edge_props = {
          protocol: p.ip_protocol == '-1' ? 'all' : p.ip_protocol,
          port_start: p.from_port || '0',
          port_end: p.to_port || '65535',
          owner: g.owner_id
        }


        # Different logic for CIDRs vs AWS groups since they have different structures
        if p.user_id_group_pairs.empty?
          # If CIDR...
          p.ip_ranges.each do |cidr|
            puts "adding cidr #{cidr}"
            src_node_uid = cidr.cidr_ip
            src_node_name = src_node_uid
            src_node = add_sg_node(src_node_uid, src_node_name, 'internet', 'cidr')
            add_sg_edge(src_node, dst_node, edge_props, g.id)
          end
        else
          # If AWS group...
          # sanity check
          p.user_id_group_pairs.each do |group|
            src_node_owner_id = group.user_id
            # If the groups are within the same account...
            if dst_node.owner_id == src_node_owner_id
              src_node_owner_id = group.user_id
              src_node_uid = group.group_id
              src_node_name = groups[src_node_uid].group_name || src_node_uid
              if groups[src_node_uid].nil?
                raise "Group '#{src_node_uid}' is not in our list of security groups, even though it was referenced by '#{dst_node.uid}'."
              end
              cluster_id = groups[src_node_uid].vpc_id || 'classic'
            # The groups are in different accounts
            else
              if group.peering_status == 'deleted'
                puts "WARNING: Outdated permission found in group '#{dst_node.name}' (#{dst_node.uid}) to group #{group.group_id} in vpc '#{group.vpc_id}'. Peering has been deleted."
                next
              end
              src_node_owner_id = group.user_id
              src_node_id = group.group_id
              src_node_uid = src_node_id
              src_node_name = src_node_owner_id + '/' + ( group.group_name || src_node_id )
              cluster_id = "account-#{src_node_owner_id}"
              puts "account-#{src_node_owner_id} for #{src_node_uid}:#{src_node_name} -> #{dst_node.uid}:#{dst_node.name}"
            end

            src_node = add_sg_node(src_node_uid, src_node_name, cluster_id, 'security-group')
            add_sg_edge(src_node, dst_node, edge_props, g.id)
          end
        end
      end
    end
    [@nodes, @edges]
  end

  private

  def add_sg_edge(tail_node, head_node, edge_props, edge_data_source, edge_class=Ec2SecurityGroupEdge)
    # sanity check
    unless tail_node && head_node && edge_props[:protocol] && edge_props[:port_start] && edge_props[:port_end]
      # debugging
      puts 'ERROR:'
      puts tail_node
      puts head_node
      puts edge_props
      raise 'bad edge props'
    end
    e = add_edge(tail_node, head_node, edge_props, edge_data_source, edge_class)
    e.type = edge_type(e)
    e
  end

  def add_sg_node(uid, name, vpc_id, type)
    n = add_node(uid, name, type, Ec2SecurityGroupNode)
    if vpc_id
      puts "adding cluster '#{vpc_id}' to node #{uid}"
      n.add_cluster('vpc', vpc_id, vpc_name(vpc_id) || vpc_id)
    else
      puts "no vpc_id for node #{uid}"
      binding.pry
    end
    n
  end

  def vpc_name(vpc_id)
    return vpc_id unless @ec2
    @vpc_name_cache ||= @ec2.vpcs.each_with_object({}) do |v, acc|
      nametag = v.tags.select { |t| t.key == 'Name' }.first
      acc[v.id] = nametag ? nametag.value : v.id
    end
    @vpc_name_cache[vpc_id]
  end

  def edge_type(e)
    case e.port_start
    when '80'
      'unencrypted'
    when '22', '443', '1194', '1514', '2221'
      'encrypted'
    end
  end

end
