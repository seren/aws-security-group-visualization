class ElbInstance < AwsInstance
  attr_accessor :src_obj, :type, :vpc_id, :id, :uid, :name, :security_groups
  def initialize(src, all_sgs, current_account_id)
    @src_obj = src
    @type = 'elb'
    @vpc_id =  src.vpc_id || 'classic'
    @account_id = current_account_id
    @uid = @account_id + '/' + src.load_balancer_name
    @id = @uid
    @name = src.load_balancer_name
    # hash of security group ids to group
    @security_groups = src.security_groups.inject({}) { |acc, sg_id| acc[sg_id] = all_sgs[sg_id]; acc }
  end
end
