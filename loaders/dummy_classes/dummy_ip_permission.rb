class DummyIpPermission
  attr_accessor :user_id_group_pairs, :ip_ranges, :ip_protocol, :from_port, :to_port
  def initialize
    self.ip_ranges = []
    self.user_id_group_pairs = []
  end
end
