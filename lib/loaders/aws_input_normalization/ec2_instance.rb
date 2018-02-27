class Ec2Instance < AwsInstance
  attr_accessor :src_obj, :type, :cluster_id, :id, :uid, :name, :security_groups
  def initialize(src, all_sgs, current_account_id)
    @src_obj = src
    @type = 'instance'
    @cluster_id =  src.vpc_id || 'classic'
    @account_id = current_account_id
    @uid = @account_id + '/' + src.id
    @id = src.id
    @name = src.tags.select { |t| t.key == 'Name'}.first&.value || src.id
    @security_groups = src.security_groups.inject({}) { |acc, sg| acc[sg.group_id] = all_sgs[sg.group_id]; acc }
    src.security_groups.map { |sg| all_sgs[sg.group_id] }
  end
end
