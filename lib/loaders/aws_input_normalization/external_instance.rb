# An instance discovered that is outside the account currently being interogated
class ExternalInstance < AwsInstance
  attr_accessor :src_obj, :type, :cluster_id, :id, :uid, :name, :account_id
  def initialize(p)
    @src_obj = p
    @account_id = p.user_id_group_pairs.first.user_id
    @cluster_id = "account-" + p.user_id_group_pairs.first.user_id
    @id = p.user_id_group_pairs.first.group_id
    @uid = @account_id + '/' + @id
    @name = @account_id + '/' + ( p.user_id_group_pairs.first.group_name || @id )
  end
end
