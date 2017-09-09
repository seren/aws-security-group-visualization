class DummyInstance
  attr_accessor :id, :vpc_id, :tags, :security_groups, :type
  def initialize
    self.security_groups = []
    self.tags = []
  end
end
