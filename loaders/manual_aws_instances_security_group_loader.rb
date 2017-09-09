# nodes == ec2 instances or CIDR addresses (or security groups outside the account )
# edges == permissions between instances/addresses/external-security-groups as defined by the assigned security groups
# clusters == vpc/internet/classic/external-account: location/owner of the instance/cidr/external-security-group

class ManualAwsInstancesSecurityGroupLoader < AwsInstancesSecurityGroupLoader

  # Stub so we don't try to actually connect
  def connect_to_aws(args)
    dummy_data = DummyData.new
    DummyEc2.new(dummy_data)
  end

  def add_inst_node(uid, name, cluster_id, type, inst=nil)
    node = add_sg_node(uid, name, cluster_id, type)
    if inst
      node.type = inst.type
    end
    node
  end

end
