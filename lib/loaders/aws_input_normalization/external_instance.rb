# An instance discovered that is outside the account currently being interogated
class ExternalInstance < AwsInstance
  attr_accessor :src_obj, :type, :vpc_id, :id, :uid, :name, :account_id
  def initialize(p)
    @src_obj = p
    @account_id = p.user_id_group_pairs.first.user_id
    @vpc_id = "account-" + p.user_id_group_pairs.first.user_id
    @id = p.user_id_group_pairs.first.group_id
    @uid = @account_id + '_' + @id
    @name = @account_id + '_' + ( p.user_id_group_pairs.first.group_name || @id )
  end
end
