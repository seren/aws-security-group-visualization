class Ec2SecurityGroupNode < Node
  attr_accessor :subgraph_id, :subgraphref, :owner_id, :vpc_id

  def initialize(uid, name, type)
    @type = type  # used to determine what type of security-group entity this is (cidr, group, etc)
    # puts "CREATED " + uid + " with type " + @type.to_s
    super
  end

  def cidr?
    @type == :cidr ? true : false
  end

  def group?
    @type == :group ? true : false
  end
end
