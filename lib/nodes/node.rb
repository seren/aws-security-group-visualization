class Node
  attr_accessor :uid, :name, :outgoing_edges, :incoming_edges, :clusters, :type

  def initialize(uid, name)
    @uid = uid
    @name = name
    @outgoing_edges = {}
    @incoming_edges = {}
    @clusters = Set.new() # could be multiple (eg. vpc, account, type)
  end

  def edges
    @outgoing_edges.merge(@incoming_edges)
  end

  def sanitize_filename(fn)
    fn.gsub(%r{[/\\.:]}, '_')
  end

  def file_name
    'node-' + sanitize_filename(uid)
  end

  def simple_name
    name.split('/')[0]
  end

  def url(depth = nil)
    depth ? file_name + "-depth_#{depth}.html" : file_name + '.html'
  end

  def add_outgoing_edge(e)
    outgoing_edges[e.uid] = e unless outgoing_edges.include?(e.uid)
  end

  def add_incoming_edge(e)
    incoming_edges[e.uid] = e unless incoming_edges.include?(e.uid)
  end

  # Add to the list of clusters this node is a member of
  def add_cluster(c_id)
    @clusters << c_id
  end

  def print
    puts "NODE: #{name}"
    puts " #{incoming_edges.size} INCOMING EDGES:"
    incoming_edges.each do |_k, v|
      puts '  ' + v.uid + '   '
    end
    puts " #{outgoing_edges.size} OUTGOING EDGES:"
    outgoing_edges.each do |_k, v|
      puts '  ' + v.uid + '   '
    end
    puts
  end

  def to_s
    name
  end

  def adjacent_nodes(depth = 1)
    if depth.zero?
      self
    else
      outgoing_edges.map { |_k, v| v.head_node.adjacent_nodes(depth - 1) } + incoming_edges.map { |_k, v| v.tail_node.adjacent_nodes(depth - 1) }
    end
  end

  def adjacent_edges(depth = 0)
    if depth.zero?
      edges.values
    else
      outgoing_edges.map { |_k, v| v.head_node.adjacent_edges(depth - 1) } + incoming_edges.map { |_k, v| v.tail_node.adjacent_edges(depth - 1) }
    end
  end
end
