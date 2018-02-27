class RdsInstance < AwsInstance
  attr_accessor :src_obj, :type, :vpc_id, :id, :uid, :name, :security_groups
  def initialize(src, all_sgs, current_account_id)
    @src_obj = src
    @type = 'rds'
    @vpc_id =  src.subnet_group.vpc_id || 'classic'
    @account_id = current_account_id
    @uid = @account_id + '/' + src.id
    @id = src.id
    @name = src.id
    # hash of security group ids to group
    @security_groups = src.vpc_security_groups.inject({}) { |acc, sg_struct| acc[sg_struct['vpc_security_group_id']] = all_sgs[sg_struct['vpc_security_group_id']]; acc }
  end
end
