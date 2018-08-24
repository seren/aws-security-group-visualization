class GraphvizWriter
  attr_reader :nodes, :edges
  attr_accessor :use_subgraphs, :output_dir

  def initialize(nodes, edges, args = {})
    @use_subgraphs = args[:use_subgraphs] || false
    @subgraphs_type = args[:subgraphs_type] || 'vpc'
    @output_dir = args[:output_dir] || '/tmp/defaultdir'
    @opts = args
    @nodes = nodes
    @edges = edges
    @min_depth = 2    # You need a depth of at least two to have edges (depth=1 would just have one node)
    @cluster_by_default = 'vpc' # The type of grouping to cluster nodes by
  end


  ### Graph and component styling ###

  # For adding shapes to nodes based on type
  def node_shape(n)
    {
      'rds' => 'Mcircle',
      'elb' => 'diamond',
      'instance' => 'box',
      'security-group' => 'ellipse',
      'cidr' => 'ellipse',
      'external-security-group' => 'doubleoctagon'
    }[n.type]&.to_sym || 'ellipse'
  end

  def edge_style(e)
    {
      'unencrypted' => 'solid',
      'encrypted' => 'bold',
      'backup' => 'dotted',
      'other' => 'dashed'
    }[e.type]&.to_sym || 'solid'
  end

  def style_the_graph(g)
    g.edge[:color] = 'grey30'
    g.edge[:fontcolor] = 'blue'
    g
  end



  ### Metric tracking ###

  # Used for metrics and work/time prediction
  def count_nodes_edges_within_level(nodes, edges, starting_node=nil, depth=@min_depth)
    if starting_node.nil?
      [nodes.count, edges.count]
    else
      graphed_nodes = Set.new
      graphed_edges = Set.new

      # Bootstrap by adding the node at the first level manually
      next_nodes = Set.new [starting_node]
      graphed_nodes.add?(starting_node)

      # Starting at the bootstrapped node at the first level, work our way out to each new level/degree-of-separation
      # Each time through, draw the edges in next_nodes and then nodes at the end of the edges (the nodes at the next level)
      # "level" = degree of separation. 1 node at level 0, all it's neighbors at level 1, all their neighbors at level 2, etc
      (depth - 1).times do |d|
        puts "Working on level #{d}"
        former_next_nodes = next_nodes
        next_nodes = Set.new
        former_next_nodes.each do |n|
          # graph the edges at my level and the nodes at the next
          n.incoming_edges.each do |_k, v|
            graphed_edges.add?(v)
            graphed_nodes.add?(v.tail_node)
            next_nodes.add?(v.tail_node) # queue up the node at the next level
          end
          n.outgoing_edges.each do |_k, v|
            graphed_edges.add?(v)
            graphed_nodes.add?(v.head_node)
            next_nodes.add?(v.head_node)
          end
        end
      end
      [graphed_nodes.count, graphed_edges.count]
    end
  end

  # Used for metrics and work/time prediction
  def count_nodes_edges_with_same_edge_properties(properties_uid = nil)
    graphed_nodes = Set.new
    graphed_edges = Set.new

    edge_matches = edges.select { |_k, v| v.properties_uid == properties_uid }
    edge_matches.each do |_k, v|
      graphed_nodes.add?(v.tail_node)
      graphed_nodes.add?(v.head_node)
      graphed_edges.add?(v)
    end
    [graphed_nodes.count, graphed_edges.count]
  end



  ### Graph-building functions ###


  # Returns a new empty graph with some customizations
  def init_graph()
    g = GraphViz.new('G', rankdir: 'LR', concentrate: 'false', remincross: 'true', ordering: 'out')
    return style_the_graph(g)
  end

  # Subgraphs are graphviz "cluster subgraphs". This function runs through the nodes and
  # generates subgraphs for the clusters that the nodes are members of
  # (ex EC2 Classic, Internet, vpc_id).
  # It adds the subgraphs to the graphviz graph and returns a mapping of
  # nodes to subgraphs. It doesn't actually populate the subgraphs.
  # It returns {node -> subgraph}
  # Maybe should be renamed: generate_subgraphs_from_clustered_nodes
  def generate_cluster_subgraphs(g)
    mapping = {}    #       nodes -> subgraph
    subgraphs = {}  # subgraph_id -> subgraph

    # If we're not using subgraphs, just map every node to the main graph and return
    unless @use_subgraphs
      @nodes.values.each { |n| mapping[n.uid] = g }
      return mapping
    end

    # Scan all nodes and build a mapping of all cluster_ids -> clusters
    @clusters ||= @nodes.inject({}) { |acc, (id, n)| acc.merge(n.clusters) { |key, a, b| a.merge(b) } }
    # Create a subgraph for each discovered cluster
    @clusters[@subgraphs_type].each do |c_id, c_name|
      subgraphs[c_id] = g.add_graph('cluster-' + c_name, label: c_name)
    end

    # Scan all nodes and build a mapping of all node-uids -> clusters
    @nodes.values.each do |n|
      # raise "Not sure how to deal with nodes that are members of multiple clusters (#{n.uid}: #{n.clusters.to_a})" if n.clusters.size > 1
      raise "Not sure how to deal with nodes that aren't members of a #{@subgraphs_type} cluster/subgraph (#{n.uid})" if n.clusters[@subgraphs_type].empty?
      raise "Couldn't find a subgraph value for key #{@subgraphs_type} in node #{n.uid}" if subgraphs[n.clusters[@subgraphs_type].keys.first].nil?
      # Assumes that nodes have one cluster
      n.clusters[@subgraphs_type].each do |c_id, c_name|
        mapping[n.uid] = subgraphs[c_id]
      end
    end

    mapping
  end


  # Given arrays of nodes and edges, and an optional starting_node and depth,
  # outputs a graphviz in-memory graph as well as the sets of edges and nodes
  # that are present in the graph.
  # If starting_node is provided, then only display nodes up to <depth> degree away
  def create_graphviz_graph(starting_node = nil, depth = @min_depth)
    puts ""
    # adds a node to the various subgraphs and arrays
    def add_node(n, node_to_subgraphs_map, graphed_nodes, next_nodes, depth, g, starting_node)
      graphed_nodes.add?(n) && node_to_subgraphs_map[n.uid].add_nodes(n.uid, label: n.name, URL: n.url(depth), shape: node_shape(n) )
      next_nodes.add?(n) # queue up the node at the next leeel
    end

    # adds an edge to the various subgraphs and arrays
    def add_edge(e, graphed_edges, g)
      graphed_edges.add?(e) && g.add_edges(e.tail_node.uid, e.head_node.uid, label: e.label, URL: e.url, style: edge_style(e))
      puts e.uid
    end

    # Give user feedback on the number and type of edges
    def output_counts(n)
      in_e = Set.new n.incoming_edges
      out_e = Set.new n.outgoing_edges
      puts "Adding #{(in_e | out_e).count} edges, #{(in_e - out_e).count} incoming, #{(out_e - in_e).count} outgoing, #{(in_e & out_e).count} both..."
    end

    g = init_graph()

    node_to_subgraphs_map = generate_cluster_subgraphs(g)
    if starting_node.nil?
      puts "No starting node. Adding everything"
      # If no starting node, graph everything
      @nodes.each do |_k, n|
        node_to_subgraphs_map[n.uid].add_nodes(n.uid, label: n.name, URL: n.url(depth), shape: node_shape(n) )
      end
      @edges.each do |_k, e|
        g.add_edges(e.tail_node.uid, e.head_node.uid, label: e.label, URL: e.url, style: edge_style(e))
      end
      # Record which nodes have actually been added to the graph
      graphed_nodes = @nodes.values
      graphed_edges = @edges.values
    else
      puts "starting_node = #{starting_node.uid}"
      next_nodes = Set.new [starting_node]
      # Get ready to record which nodes have actually been added to the graph
      graphed_nodes = Set.new
      graphed_edges = Set.new

      # Bootstrap by adding the node at the first level manually, unless it's already been added
      node_to_subgraphs_map[starting_node.uid].add_nodes(starting_node.uid, label: starting_node.name, URL: starting_node.url(depth), shape: node_shape(starting_node) ) unless graphed_nodes.add?(starting_node).nil?

      # Starting at the bootstrapped node at the first level, work our way out to each new level/degree-of-separation
      # Each time through, add the edges in next_nodes and then nodes at the end of the edges (the nodes at the next level)
      # "level" = degree of separation. 1 node at level 0, all it's neighbors at level 1, all their neighbors at level 2, etc
      (depth - 1).times do
       former_next_nodes = next_nodes
        next_nodes = Set.new
        former_next_nodes.each do |n|
          output_counts(n)
          # graph the edges at my level and the nodes at the next
          puts "++++"
          n.incoming_edges.each do |_k, e|
            add_node(e.tail_node, node_to_subgraphs_map, graphed_nodes, next_nodes, depth, g, starting_node)
            add_edge(e, graphed_edges, g)
          end
          puts '---'
          n.outgoing_edges.each do |_k, e|
            add_node(e.head_node, node_to_subgraphs_map, graphed_nodes, next_nodes, depth, g, starting_node)
            add_edge(e, graphed_edges, g)
          end
          puts "==="
        end
      end
    end
    [g, graphed_nodes, graphed_edges]
  end

  # Given an arrays edges, a properties string, and an optional depth,
  # finds all matching edges and returns a graphviz graph as well as the sets of
  # edges and nodes that are present in the graph.
  # Used to produce graphs per port/proto type (eg. ssh access)
  def create_graphviz_graph_for_similar_edges(properties_uid = nil, depth = @min_depth)
    g = init_graph()

    node_to_subgraphs_map = generate_cluster_subgraphs(g)

    graphed_nodes = Set.new
    graphed_edges = Set.new

    edge_matches = @edges.select { |_k, e| e.properties_uid == properties_uid }
    edge_matches.each do |_k, e|
      node_to_subgraphs_map[e.tail_node.uid].add_nodes(e.tail_node.uid, label: e.tail_node.name, URL: e.tail_node.url(depth), shape: node_shape(e.tail_node) ) unless graphed_nodes.add?(e.tail_node).nil?
      node_to_subgraphs_map[e.head_node.uid].add_nodes(e.head_node.uid, label: e.head_node.name, URL: e.head_node.url(depth), shape: node_shape(e.head_node) ) unless graphed_nodes.add?(e.head_node).nil?
      g.add_edges(e.tail_node.uid, e.head_node.uid, label: e.label, URL: e.url, style: edge_style(e)) unless graphed_edges.add?(e).nil?
    end
    [g, graphed_nodes, graphed_edges]
  end



  ### File-building and output functions ###

  def output_individual_files_for_all_edges()
    # Build a list of all ids and filenames (with duplicates if port & protocol are the same but the nodes different)
    uniq_properties_uids = @edges.map { |_k, e| [e.properties_uid, e.port_and_proto_file_name] }.uniq
    # Create files for each unique port/proto combo
    uniq_properties_uids.each { |x| output_files_for_individual_edge_type(x[0], x[1]) }
  end

  def output_files_for_individual_edge_type(properties_uid, port_and_proto_file_name)
    max_edge_count = 800
    node_count, edge_count = count_nodes_edges_with_same_edge_properties(properties_uid)
    filename_no_extension = port_and_proto_file_name.to_s
    filepath_no_extension = "#{@output_dir}/#{filename_no_extension}"
    FileUtils.mkdir_p(@output_dir)
    g, graphed_nodes, _graphed_edges = create_graphviz_graph_for_similar_edges(properties_uid)
    if edge_count > max_edge_count
      puts "Skipping creating graph for #{filename_no_extension} with #{node_count}/#{nodes.count} nodes and #{edge_count}/#{@edges.count} edges. Too many edges (it would take forever and the graph would be unusable)"
      # copy no-image-available-too-many-edges.png "#{filepath_no_extension}.png")
    else
      puts "Creating graph for #{filename_no_extension} with #{node_count}/#{nodes.count} nodes and #{edge_count}/#{@edges.count} edges..."
      write_out_asset_files(g, filepath_no_extension)
    end
    File.open("#{filepath_no_extension}.html", 'w') do |f|
      f.puts "<html><head><title>#{properties_uid}</title></head><body>"
      f.puts "<h3>#{properties_uid}</h3>"
      f.puts page_header("#{filename_no_extension}.html")
      f.puts '<br>'
      if edge_count > max_edge_count
        f.puts "<h2>Image not available. Too many edges(#{edge_count}) to display.</h2>"
      else
        f.puts image_with_map(filename_no_extension, filepath_no_extension)
        # We don't bother generating edge links since there's only one on this page
      end
      f.puts node_links_footer(graphed_nodes)
      f.puts page_footer
      f.puts '</body></html>'
    end
  end

  def output_individual_files_for_all_nodes(depth = @min_depth, maxdepth = nil)
    @nodes.each do |_k, n|
      output_files_for_individual_node(n, depth, maxdepth)
    end
  end

  # Generate the files for a node, at all depths (degrees of separation) specified
  def output_files_for_individual_node(node, depth = @min_depth, maxdepth = nil)
    node_count, edge_count = count_nodes_edges_within_level(@nodes, @edges, node, depth)
    puts "Creating graph with #{node_count}/#{nodes.count} nodes and #{edge_count}/#{@edges.count} edges."
    maxdepth ||= depth
    # Make the pages for different depths
    (depth..maxdepth).map do |current_depth|
      filename_no_extension = "#{node.file_name}-depth_#{current_depth}"
      filepath_no_extension = "#{@output_dir}/#{filename_no_extension}"
      puts "creating graph for #{filename_no_extension}..."
      g, graphed_nodes, graphed_edges = create_graphviz_graph(node, current_depth)
      FileUtils.mkdir_p(@output_dir)
      write_out_asset_files(g, filepath_no_extension)
      File.open("#{filepath_no_extension}.html", 'w') do |f|
        f.puts "<html><head><title>#{node.name} (#{node.uid})</title></head><body>"
        f.puts "<h3>#{node.name} (#{node.uid})</h3>"
        f.puts page_header("#{filename_no_extension}.html")
        if depth != maxdepth
          f.puts ' | Depth: ' + (@min_depth..maxdepth).map { |d| d == current_depth ? d : "<a href=\"#{node.url(d)}\">#{d}</a>" }.join(' ')
        end
        f.puts '<br>'
        f.puts image_with_map(filename_no_extension, filepath_no_extension)
        f.puts node_and_edge_links_footer(graphed_nodes, graphed_edges, current_depth)
        f.puts page_footer
        f.puts '</body></html>'
      end
    end
  end

  # This writes out the files for _one_ image, that of the complete graph
  def output_files_for_complete_graph(filename_no_extension = 'everything')
    max_edge_count = 1200
    filepath_no_extension = "#{@output_dir}/#{filename_no_extension}"
    FileUtils.mkdir_p(@output_dir)
    edge_count = edges.count
    g, graphed_nodes, graphed_edges = create_graphviz_graph
    if edge_count > max_edge_count
      puts "Skipping creating graph for #{filename_no_extension} with #{nodes.count} nodes and #{edges.count} edges. Too many edges (it would take forever and the graph would be unusable)"
      puts "Just writing a list of edges and nodes that would have been part of the graph"
    else
      puts "Creating graph with #{nodes.count} nodes and #{edges.count} edges."
      g, graphed_nodes, graphed_edges = create_graphviz_graph
      puts "writing #{@output_dir}/#{filename_no_extension}.png"
      write_out_asset_files(g, filepath_no_extension)
      g.output(xdot: filepath_no_extension + '-xdot.gv')
    end
    File.open("#{@output_dir}/#{filename_no_extension}.html", 'w') do |f|
      f.puts '<html><head><title>' + filename_no_extension + '</title></head><body>'
      f.puts page_header(filename_no_extension + '.html')
      if edge_count > max_edge_count
        f.puts "<h2>Image not available. Too many edges(#{edge_count}) to display.</h2>"
      else
        f.puts image_with_map(filename_no_extension, filepath_no_extension)
      end
      f.puts node_and_edge_links_footer(graphed_nodes, graphed_edges, @min_depth)
      f.puts page_footer
      f.puts '</body></html>'
    end
  end

  # Writes graph data in all needed formats (image, map, dot file)
  def write_out_asset_files(g, filepath_no_extension, types=['png', 'cmap', 'dot'])
    types.each do |t|
      puts "writing #{filepath_no_extension}.#{t}"
      g.output(t.to_sym => "#{filepath_no_extension}.#{t}")
    end
  end



  ### HTML contructors ###

  # Returns the appropriate html for an image with associate clickable map
  def image_with_map(filename_no_extension, filepath_no_extension)
    str  = "<img src='#{filename_no_extension}.png' usemap='#mainmap'>"
    str += '<map name="mainmap">'
    str += File.open("#{filepath_no_extension}.cmap").readlines.join("\n")
    str += '</map><br>'
  end

  # Returns the html for node and edge reference links
  def node_and_edge_links_footer(ns, es, current_depth)
    node_links_footer(ns, current_depth) + edge_links_footer(es)
  end

  # Generate links to the pages for the nodes in the argument array at the current depth
  def node_links_footer(ns, current_depth=@min_depth)
    str  = '<div style="font-size: 62.5%;">'
    str += "<br><br><b>Nodes:</b><br>\n"
    str += ns.sort_by { |n| n.name }.flatten.uniq.map { |n| "<a href='#{n.url(current_depth)}'>#{n.name} (#{n.uid})</a>" }.join("<br>\n")
    str += '</div>'
  end

  # Generate links to the pages for the edges in the argument array
  def edge_links_footer(es)
    str  = '<div style="font-size: 62.5%;">'
    str += "<br><br><b>Edges:</b><br>\n"
    # Multiple edges map to the same port-protocol file, so make sure we don't print dups
    str += es.sort_by(&:uid).flatten.map { |e| "<a href='#{e.url}'>#{e.properties_uid}</a>" }.uniq.join("<br>\n")
    str += '</div>'
  end

  def page_header(filename)
    link = @use_subgraphs ? "<a href=\"../non-clustered/#{filename}\">non-clustered</a>" : "<a href=\"../clustered/#{filename}\">clustered</a>"
    "<a href=\"everything.html\">Big picture</a> | View #{link} | <i>Generated: #{Time.now}<br>"
  end

  def page_footer
    "<hr><div style='font-size: 62.5%;'><i>Generated: #{Time.now}</i><br></div>"
   end
end
