class CidrInstance < AwsInstance
  attr_accessor :src_obj, :type, :vpc_id, :id, :uid, :name
  def initialize(permission, cidr, all_sgs=nil, current_account_id=nil)
    @src_obj = permission
    @type = 'cidr'
    @vpc_id = 'internet'
    @uid = cidr.cidr_ip
    @id = @uid
    @name = cidr.cidr_ip
  end
end
