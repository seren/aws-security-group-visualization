# tail = src
# head = dst

class Loader

  def initialize(*)
    @nodes = {}  # uid -> obj
    @edges = {}  # uid -> obj
    @clusters = {}  # uid -> obj
  end

  # Needs to be implemented
  def load_groups
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  private

  def add_edge(tail_node, head_node, edge_props, edge_data_source, edge_class=Edge)
    e = edge_class.new(tail_node, head_node, edge_props)
    if @edges[e.uid]
      puts 'edge already exists: '+e.uid
      e = @edges[e.uid]
    else
      @edges[e.uid] = e
      head_node.add_incoming_edge(e)
      tail_node.add_outgoing_edge(e)
      puts 'added edge '+e.to_s
    end
    e.add_edge_data_source(edge_data_source)
    e
  end

  # creates a node/cluster/etc and adds it to the tracking hash
  def add_and_aggregate_generic(uid, name, type, obj_class, aggregator)
    if aggregator[uid]
      puts "#{obj_class} already exists. Uid: " + uid
      # sanity check
      if aggregator[uid].type != type
        raise "Existing #{obj_class} '#{uid}' type (#{aggregator[uid].type}) doesn't match new duplicate (supposedly) #{obj_class}'s type (#{type})"
      end
      aggregator[uid]
    else
      o = obj_class.new(uid, name, type)
      o.type = type
      aggregator[o.uid] = o
      puts "Added #{obj_class} " + o.to_s
      o
    end

  def add_node(uid, name, type, node_class=Node)
    add_and_aggregate_generic(uid, name, type, node_class, @nodes)
  end

  def add_cluster(uid, name, type)
    add_and_aggregate_generic(uid, name, 'cluster', Cluster, @clusters)
  end
end
