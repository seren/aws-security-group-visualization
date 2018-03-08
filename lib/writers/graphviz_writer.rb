class GraphvizWriter
  attr_reader :nodes, :edges
  attr_accessor :use_subgraphs, :output_dir

  def initialize(nodes, edges, args = {})
    @use_subgraphs = args[:use_subgraphs] || false
    @subgraphs_of_type = args[:subgraphs_of_type] || 'vpc'
    @output_dir = args[:output_dir] || '/tmp/defaultdir'
    @opts = args
    @nodes = nodes
    @edges = edges
    @min_depth = 2    # You need a depth of at least two to have edges (depth=1 would just have one node)
    @cluster_by_default = 'vpc' # The type of grouping to cluster nodes by
  end

  def node_page_title(n)
    n.name + ' ' + n.uid
  end


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


  # Subgraphs are graphviz clusters. This function runs through the nodes and
  # generates subgraphs for the clusters that the nodes are members of
  # (ex EC2 Classic, Internet, vpc_id).
  # It doesn't actually populate the subgraph.
  # It returns {node -> subgraph}
  # Maybe should be renamed: generate_subgraphs_from_clustered_nodes
  def generate_subgraph_clusters(g)
    # nodes -> subgraph
    mapping = {}
    # subgraph_id -> subgraph
    subgraphs = {}


    unless @use_subgraphs
      # Just map every node to the main graph
      @nodes.values.each { |n| mapping[n.uid] = g }
    else
      # Build a master hash of all clusters from the nodes
      @clusters ||= @nodes.inject({}) { |acc, (id, n)| acc.merge(n.clusters) { |key, a, b| a.merge(b) } }
      # Create subgraphs for each cluster
      @clusters[@subgraphs_of_type].each do |c_id, c_name|
        subgraphs[c_id] = g.add_graph('cluster-' + c_name, label: c_name)
      end

      @nodes.values.each do |n|
        # raise "Not sure how to deal with nodes that are members of multiple clusters (#{n.uid}: #{n.clusters.to_a})" if n.clusters.size > 1
        raise "Not sure how to deal with nodes that aren't members of a #{@subgraphs_of_type} cluster/subgraph (#{n.uid})" if n.clusters[@subgraphs_of_type].empty?
        raise "Couldn't find a subgraph value for key #{@subgraphs_of_type} in node #{n.uid}" if subgraphs[n.clusters[@subgraphs_of_type].keys.first].nil?
        n.clusters[@subgraphs_of_type].each do |c_id, c_name|
          mapping[n.uid] = subgraphs[c_id]
        end
      end

    end
    mapping
  end






  # Creates a graphviz graph from arrays of nodes and edges
  # If starting_node is provided, then only display nodes up to <depth> degree away
  def create_graphviz(starting_node = nil, depth = @min_depth)
    g = GraphViz.new('G', rankdir: 'LR', concentrate: 'false', remincross: 'true', ordering: 'out')
    g.edge[:color] = 'grey30'
    g.edge[:fontcolor] = 'blue'

    node_to_subgraphs = generate_subgraph_clusters(g)
    if starting_node.nil?
      puts "No starting node. adding everything"
      # If no starting node, graph everything
      @nodes.each do |_k, v|
        node_to_subgraphs[v.uid].add_nodes(v.uid, label: v.name, URL: v.url(depth), shape: node_shape(v) )
      end
      @edges.each do |_k, v|
        g.add_edges(v.tail_node.uid, v.head_node.uid, label: v.label, URL: v.url, style: edge_style(v))
      end
      # Record which nodes have actually been added to the graph
      graphed_nodes = @nodes.values
      graphed_edges = @edges.values
    else
      next_nodes = Set.new [starting_node]
      # Get ready to record which nodes have actually been added to the graph
      graphed_nodes = Set.new
      graphed_edges = Set.new

      # Bootstrap by adding the node at the first level manually
      node_to_subgraphs[starting_node.uid].add_nodes(starting_node.name, URL: starting_node.url(depth), shape: node_shape(starting_node) ) unless graphed_nodes.add?(starting_node).nil?

      # Starting at the bootstrapped node at the first level, work our way out to each new level/degree-of-separation
      # Each time through, add the edges in next_nodes and then nodes at the end of the edges (the nodes at the next level)
      # "level" = degree of separation. 1 node at level 0, all it's neighbors at level 1, all their neighbors at level 2, etc
      (depth - 1).times do |d|
       former_next_nodes = next_nodes
        next_nodes = Set.new
        former_next_nodes.each do |n|
          in_e = Set.new n.incoming_edges
          out_e = Set.new n.outgoing_edges
          # graph the edges at my level and the nodes at the next
          puts "Adding #{(in_e | out_e).count} edges, #{(in_e - out_e).count} incoming, #{(out_e - in_e).count} outgoing, #{(in_e & out_e).count} both..."
          n.incoming_edges.each do |_k, v|
            graphed_edges.add?(v) && g.add_edges(v.tail_node.name, v.head_node.name, label: v.label, URL: v.url, style: edge_style(v))
            graphed_nodes.add?(v.tail_node) && node_to_subgraphs[v.tail_node.uid].add_nodes(v.tail_node.name, URL: v.tail_node.url(depth), shape: node_shape(v.tail_node) )
            next_nodes.add?(v.tail_node) # queue up the node at the next level
          end
          n.outgoing_edges.each do |_k, v|
            graphed_edges.add?(v) && g.add_edges(v.tail_node.name, v.head_node.name, label: v.label, URL: v.url, style: edge_style(v))
            graphed_nodes.add?(v.head_node) && node_to_subgraphs[v.head_node.uid].add_nodes(v.head_node.name, URL: v.head_node.url(depth), shape: node_shape(v.head_node) )
            next_nodes.add?(v.head_node)
          end
        end
      end
    end
    [g, graphed_nodes, graphed_edges]
  end

  # Creates a graphviz graph from arrays of edges and their nodes that match a port/protocol combination
  def create_graphviz_for_similar_edges(properties_uid = nil, depth = @min_depth)
    g = GraphViz.new('G', rankdir: 'LR', concentrate: 'false', remincross: 'true', ordering: 'out')
    g.edge[:color] = 'grey30'
    g.edge[:fontcolor] = 'blue'

    # Subgraphs = graphviz clusters
    node_to_subgraphs = generate_subgraph_clusters(g)

    graphed_nodes = Set.new
    graphed_edges = Set.new

    edge_matches = @edges.select { |_k, v| v.properties_uid == properties_uid }
    edge_matches.each do |_k, v|
      node_to_subgraphs[v.tail_node.uid].add_nodes(v.tail_node.uid, label: v.tail_node.name, URL: v.tail_node.url(depth), shape: node_shape(v.tail_node) ) unless graphed_nodes.add?(v.tail_node).nil?
      node_to_subgraphs[v.head_node.uid].add_nodes(v.head_node.uid, label: v.head_node.name, URL: v.head_node.url(depth), shape: node_shape(v.head_node) ) unless graphed_nodes.add?(v.head_node).nil?
      g.add_edges(v.tail_node.uid, v.head_node.uid, label: v.label, URL: v.url, style: edge_style(v)) unless graphed_edges.add?(v).nil?
    end
    [g, graphed_nodes, graphed_edges]
  end

  def output_individual_files_for_all_edges()
    # Build a list of all ids and filenames (with duplicates if port & protocol are the same but the nodes different)
    uniq_properties_uids = @edges.map { |_k, v| [v.properties_uid, v.port_and_proto_file_name] }.uniq
    # Create files for each unique port/proto combo
    uniq_properties_uids.each { |x| output_files_for_individual_edge_type(x[0], x[1]) }
  end

  def output_files_for_individual_edge_type(properties_uid, port_and_proto_file_name)
    max_edge_count = 800
    node_count, edge_count = count_nodes_edges_with_same_edge_properties(properties_uid)
    filename_no_extension = port_and_proto_file_name.to_s
    filepath_no_extension = "#{@output_dir}/#{filename_no_extension}"
    FileUtils.mkdir_p(@output_dir)
    g, graphed_nodes, _graphed_edges = create_graphviz_for_similar_edges(properties_uid)
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
    @nodes.each do |_k, v|
      output_files_for_individual_node(v, depth, maxdepth)
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
      g, graphed_nodes, graphed_edges = create_graphviz(node, current_depth)
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
    g, graphed_nodes, graphed_edges = create_graphviz
    if edge_count > max_edge_count
      puts "Skipping creating graph for #{filename_no_extension} with #{nodes.count} nodes and #{edges.count} edges. Too many edges (it would take forever and the graph would be unusable)"
    else
      puts "Creating graph with #{nodes.count} nodes and #{edges.count} edges."
      g, graphed_nodes, graphed_edges = create_graphviz
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

  def write_out_asset_files(g, filepath_no_extension, types=['png', 'cmap', 'dot'])
    types.each do |t|
      puts "writing #{filepath_no_extension}.#{t}"
      g.output(t.to_sym => "#{filepath_no_extension}.#{t}")
    end
  end

  def image_with_map(filename_no_extension, filepath_no_extension)
    str  = "<img src='#{filename_no_extension}.png' usemap='#mainmap'>"
    str += '<map name="mainmap">'
    str += File.open("#{filepath_no_extension}.cmap").readlines.join("\n")
    str += '</map><br>'
  end

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
