class Ec2SecurityGroupInstanceEdge < Ec2SecurityGroupEdge

  # label with the sources of this edge (the security groups that had this edge/permission)
  def label
    port_label + ' (' + @edge_data_sources.map{ |g| g.group_name || g.group_id }.join(' ') + ')'
  end

end
