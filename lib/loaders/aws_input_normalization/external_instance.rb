# An instance discovered that is outside the account currently being interogated
class ExternalInstance < AwsInstance
  attr_accessor :src_obj, :type, :vpc_id, :id, :uid, :name, :account_id
  def initialize(p, group)
    @src_obj = p
    @account_id = group.user_id
    @vpc_id = "account-" + group.user_id
    @id = group.group_id
    @uid = @account_id + '_' + @id
    @name = @account_id + '_' + ( group.group_name || @id )
  end
end
