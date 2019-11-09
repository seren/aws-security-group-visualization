class Cluster
  attr_accessor :uid, :name, :type, :parent_cluster, :child_clusters

  # Lower numbers encompass clusters with higher numbers
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

  # True if this cluster's type encompasses the given one's type (this cluster's
  # type has a lower hierarcy number). For example, an account cluster would
  # contain a vpc cluster.
  def contains?(cluster)
    @cluster_hierarchy[self.type] > @cluster_hierarchy[cluster.type]
  end


  # def uid
  #   "tail-#{tail_node ? tail_node.uid : ''}_head-#{head_node ? head_node.uid : ''}"
  # end

end

