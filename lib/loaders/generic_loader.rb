# tail = src
# head = dst

class Loader

  def initialize(*)
    @nodes = {}
    @edges = {}
    @clusters = {}  # cluster_id -> cluster_name  (ex. vpc_id -> vpc_name)
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

  def add_node(uid, name, type, node_class=Node)
    puts "Adding #{type} node #{uid} (#{name})"
    if @nodes[uid]
      puts "Node already exists. Uid: " + uid
      # sanity check
      if @nodes[uid].type != type
        raise "Existing node '#{uid}' type (#{@nodes[uid].type}) doesn't match new duplicate (supposedly) node's type (#{type})"
      end
      @nodes[uid]
    else
      n = node_class.new(uid, name)
      n.type = type
      @nodes[n.uid] = n
      n
    end
  end
end
