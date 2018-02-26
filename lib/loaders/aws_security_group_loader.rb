# tail = src
# head = dst

# nodes == ec2 security groups or CIDR addresses
# edges == permissions between groups/addresses
# clusters == vpcs/ec2-classic/external-accounts/internet: location/owner of the security-group/cidr

class AwsSecurityGroupLoader < Loader

  def initialize(args = {})
    @ec2, @elb, @rds, @sts = connect_to_aws(args)
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
    # Aws.config.update(logger: Logger.new($stdout))
    [
      Aws::EC2::Resource.new(region: args[:region]),
      Aws::ElasticLoadBalancingV2::Resource.new(region: args[:region]),
      Aws::RDS::Resource.new(region: args[:region]),
      Aws::STS::Client.new(region: args[:region])
    ]
  end


  def load_groups
    # Build a group_id -> group map so we can do lookups easily
    groups = {}
    @ec2.security_groups.each { |g| groups[g.id] = g }

    groups.values.each do |g|
      g.ip_permissions.each do |p|
        dst_node_uid = g.group_id
        dst_node_name = g.group_name
        puts "dst_node g: #{g}"
        dst_node = add_sg_node(dst_node_uid, dst_node_name, g.vpc_id || 'classic', 'security-group')
        dst_node.owner_id = g.owner_id

        # Different logic for CIDRs vs AWS groups since they have different structures
        if p.user_id_group_pairs.empty?
          # If CIDR...
          src_node_uid = p.ip_ranges.first.cidr_ip
          src_node_name = src_node_uid
          src_node = add_sg_node(src_node_uid, src_node_name, 'internet', 'cidr')
        else
          # If AWS group...
          src_node_owner_id = p.user_id_group_pairs.first.user_id
          # If the groups are within the same account...
          if dst_node.owner_id == src_node_owner_id
            src_node_owner_id = p.user_id_group_pairs.first.user_id
            src_node_uid = p.user_id_group_pairs.first.group_id
            src_node_name = groups[src_node_uid].group_name || src_node_uid
            if groups[src_node_uid].nil?
              raise "Group '#{src_node_uid}' is not in our list of security groups, even though it was referenced by '#{dst_node_uid}'."
            end
            cluster_id = groups[src_node_uid].vpc_id || 'classic'
          # The groups are in different accounts
          else
            if p.user_id_group_pairs.first.peering_status == 'deleted'
              puts "WARNING: Outdated permission found in group '#{dst_node_name}' (#{dst_node_uid}) to group #{p.user_id_group_pairs.first.group_id} in vpc '#{p.user_id_group_pairs.first.vpc_id}'. Peering has been deleted."
              next
            end
            src_node_owner_id = p.user_id_group_pairs.first.user_id
            src_node_id = p.user_id_group_pairs.first.group_id
            src_node_uid = src_node_owner_id + '/' + src_node_id
            src_node_name = src_node_owner_id + '/' + ( p.user_id_group_pairs.first.group_name || src_node_id )
            cluster_id = "account-#{src_node_owner_id}"
            puts "account-#{src_node_owner_id} for #{src_node_uid}:#{src_node_name} -> #{dst_node_uid}:#{dst_node_name}"
          end

          src_node = add_sg_node(src_node_uid, src_node_name, cluster_id, 'security-group')
        end
        src_port = p.from_port || '0'
        dst_port = p.to_port || '65535'
        protocol = p.ip_protocol == '-1' ? 'all' : p.ip_protocol
        edge_props = {
          protocol: protocol,
          port_start: src_port,
          port_end: dst_port,
          owner: g.owner_id
        }
        add_sg_edge(src_node, dst_node, edge_props, g.id)
      end
    end
    [@nodes, @edges, @clusters]
  end

  private

  def add_sg_edge(tail_node, head_node, edge_props, edge_data_source, edge_class=Ec2SecurityGroupEdge)
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

  def add_sg_node(uid, name, cluster_id, type)
    n = add_node(uid, name, type, Ec2SecurityGroupNode)
    if cluster_id
      puts "adding cluster_id '#{cluster_id}' to node #{uid}"
      n.add_cluster(cluster_id)
      @clusters[cluster_id] = vpc_name(cluster_id) || cluster_id
    else
      puts "no cluster_id for node #{uid}"
      binding.pry
    end
    n
  end

  def vpc_name(vpc_id)
    return id unless @ec2
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
