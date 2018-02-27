class Ec2SecurityGroupNode < Node
  attr_accessor :subgraph_id, :subgraphref, :owner_id, :vpc_id

  def initialize(uid, name, type)
    # # When we set the name, set the type and the subgraph_id
    # ip_with_subnet = %r{\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}(/\d\d?)?\z}
    # @type = name.match(ip_with_subnet) ? :cidr : :group
    @type = type
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
