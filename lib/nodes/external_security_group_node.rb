class ExternalSecurityGroupNode < Ec2SecurityGroupNode

  def initialize(uid, name)
    super
  end

  def type()
    'external-security-group'
  end
end
