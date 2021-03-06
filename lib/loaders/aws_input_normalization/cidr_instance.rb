class CidrInstance < AwsInstance
  attr_accessor :src_obj, :type, :vpc_id, :id, :uid, :name
  def initialize(permission, all_sgs=nil, current_account_id=nil)
    @src_obj = permission
    @type = 'cidr'
    @vpc_id = 'internet'
    @uid = permission.ip_ranges.first.cidr_ip
    @id = @uid
    @name = permission.ip_ranges.first.cidr_ip
  end
end
