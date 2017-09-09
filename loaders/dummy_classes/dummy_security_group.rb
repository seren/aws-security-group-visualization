class DummySecurityGroup
  attr_accessor :group_name, :id, :group_id, :vpc_id, :owner_id, :ip_permissions
  def initialize
    self.ip_permissions = []
  end
end
