# Also known as compositeedge, since it can be an edge formed from mulitple other edges/groups/relations

class Edge
  attr_accessor :tail_node, :head_node, :edge_data_sources, :type

  def initialize(tail_node, head_node, _edge_props)
    self.head_node = head_node
    self.tail_node = tail_node
    self.edge_data_sources = Set.new()
  end

  # Combination of edge properties and node properties. Intended to uniquely id an edge
  def uid
    "tail-#{tail_node ? tail_node.uid : ''}_head-#{head_node ? head_node.uid : ''}"
  end

  # Like uid, but doesn't include the node uids. Intended to help find edges with
  # identical properties. Implementation is specific to the edge type and its properties
  def properties_uid
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def sanitize_filename(fn)
    fn.gsub(%r{[/\\.]}, '_')
  end

  def file_name
    'edge-' + sanitize_filename(properties_uid)
  end

  def url
    file_name + '.html'
  end

  # Sources are where the edges came from. There can be multiple sources
  # for an edge (ex. multiple security groups assigned to an instance contain
  # identical permissions)
  def add_edge_data_source(r)
    edge_data_sources << r
  end

  def composite?
    self.edge_data_sources.size > 0
  end

  def label
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def label_with_sources(*)
    raise NotImplementedError,
      "This #{self.class} cannot respond to:"
  end

  def to_s
    "#{uid}: #{tail_node.name} -> #{head_node.name}"
  end

  def print
    puts "EDGE: \"#{uid}\""
    puts " #{tail_node.name} -> #{head_node.name}"
    puts
  end
end

