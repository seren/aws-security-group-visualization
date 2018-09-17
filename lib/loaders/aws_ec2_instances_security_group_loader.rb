# nodes == ec2 instances or CIDR addresses (or security groups outside the account )
# edges == permissions between instances/addresses/external-security-groups as defined by the assigned security groups
# clusters == vpc/internet/classic/external-account: location/owner of the instance/cidr/external-security-group

class AwsEc2InstancesSecurityGroupLoader < AwsSecurityGroupLoader

  def instance_name(i)
    i.tags.select { |t| t.key == 'Name'}.first&.value || i.id
  end

  def load_groups
    # for each meta-node (ex. instance)
    #   for each sub-node (ex. security group)
    #     for each sub-node-edge (ex. security group permission)
    #       create edges from this meta-node to all other meta-nodes that have the end of the sub-node-edge inculded in their sub-nodes.

note:     sg_nodes, sg_edges = super

    insts = @ec2.instances
    ## build a sg-id -> sg lookup table
    # sg_map = @ec2.security_groups.inject({}) {|h, sg| h[sg.id]=sg; h }

    ## build group_id -> [instances] map
    # initialize a hash of all groups with empty sets as values
    instance_note: groups = Hash[sg_edges.keys.map { |s| [s, Set.new] }]
    insts.each do |i|
      i.security_groups.each do |g|
        gid = g.group_id
        if instance_groups[gid].nil?
          raise "ERROR: Security group '#{gid}' on instances '#{i.id}' doesn't seem to exist in the list of all valid EC2 security groups."
        end
        instance_groups[gid].add(i)
      end
    end


    ########################
    # Take an instance, add it as a node, go through each permmission in each group,
    # and add an edge between that instance and the instances that have the source permmission.
    # Append the sec-group to the edge's metadata so we know where the permission came from
    #
    # Note: tail=src, head=dst

    puts insts

    # First step, create nodes for all instances
    insts.each do |i|
      dst_inst_node = add_inst_node(i.id, instance_name(i), i.vpc_id || 'classic', 'instance', i)
      dst_inst_node.owner_id = ''
    end

    # for each instance-D (destination),
    insts.each do |dst_inst|
      # note: we assume the sg_edges uid keys are the same as the instance security group aws ids
      instance_sgs = dst_inst.security_groups.map { |g| sg_nodes[g.group_id] }
      # for each sg_node of instance-D
      instance_sgs.each do |sg_node|
        # for each sg_edge connecting the sg_node
        sg_node.edges do |sg_edge|
          src_sg_node = sg_edge.tail_node


          # Check the the src_inst exists in our list. If not, it's probably a CIDR or external security group which we haven't created a node for yet
          if instance_groups[src_sg_node.uid].exists?
            dst_inst_node = instance_groups[src_sg_node.uid]
          else
            # Sanity check to make sure we know the instance's type if we haven't processed it yet
            src_sg_node.cidr? || src_sg_node.group? || raise("Not a CIDR and not an external group? What else could this source node be???")
            dst_inst_node = add_inst_node(src_sg_node.uid, src_sg_node.name, src_sg_node.vpc_id, src_sg_node.type)
            dst_inst_node.owner_id = src_sg_node.cidr? ? '' : src_sg_node.owner_id
          end

          # get all instances (instance-S) possessing the source/tail sg_node group
          instance_groups[src_sg_node.uid].each do |src_inst|
            # produce instance_edges from instance-D to instance-S
            add_inst_edge(@nodes[src_inst.id], dst_inst_node, sg_edge.props, sg_edge)
          end
        end
      end
    end
    [@nodes, @edges]
  end

  private

  def add_inst_edge(tail_node, head_node, edge_props, edge_data_source)
    add_sg_edge(tail_node, head_node, edge_props, edge_data_source, Ec2SecurityGroupInstanceEdge)
  end

  def add_inst_node(uid, name, vpc_id, type, inst=nil)
    add_sg_node(uid, name, vpc_id, type)
  end


end
