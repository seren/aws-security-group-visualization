# A normalized representation of an AWS entity that has security groups
class AwsInstance

  # node is a reference to the Node object created from this AwsInstance
  attr_accessor :node

  def initialize(src)
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def src_obj
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def type
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def cluster_id
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def account_id
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def uid
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  # Needs to match the string that other edge objects reference (
  def id
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def name
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def security_groups
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

end
