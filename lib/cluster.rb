class Cluster
  attr_accessor :uid, :name, :type, :parent_cluster, :child_clusters

  # Lower numbers = more expansive (outer) groupsing
  @cluster_hierarchy = {
    account: 1,
    region: 2,
    vpc: 3
  }


  def initialize(uid, name, type)
    self.type = type
    self.uid = uid
    self.name = name
    self.child_clusters = []
  end

  # True if this cluster's type is outside the given one
  # (this cluster's priority is higher)
  def contains?(cluster)
    @cluster_hierarchy[self.type] > @cluster_hierarchy[cluster.type]
  end


  # def uid
  #   "tail-#{tail_node ? tail_node.uid : ''}_head-#{head_node ? head_node.uid : ''}"
  # end

end

