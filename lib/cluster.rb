class Cluster
  attr_accessor :uid, :name, :type, :parent_cluster, :child_clusters

  def initialize(uid, name, type)
    self.type = type
    self.uid = uid
    self.name = name
    self.child_clusters = []
  end

  # def uid
  #   "tail-#{tail_node ? tail_node.uid : ''}_head-#{head_node ? head_node.uid : ''}"
  # end

end

