class Manager
  attr_reader :nodes, :edges
  attr_accessor :use_subgraphs, :opts

  def initialize(args = {})
    @use_subgraphs = args[:use_subgraphs] || false
    @opts = args
    # @nodes = {}
    # @edges = {}
    @graph_types = {}  # can store multiple node/edge types
  end

  def load(type=:manual)
    loadermap = {
      security_groups: AwsSecurityGroupLoader,
      instance_security_groups: AwsAllInstancesSecurityGroupLoader,
      manual: ManualAwsSecurityGroupLoader,
      instance_manual: ManualAwsInstancesSecurityGroupLoader
    }

    puts @opts
    @graph_types[type] ||= {nodes: {}, edges: {}}
    if @opts.has_key? :profile_array
      @opts[:profile_array].each do |profile|
        loader = loadermap[type].new()
        loader.connect_to_aws({region: "us-east-1", profile: profile})
        nodes, edges = loader.load_groups
        # @nodes.merge!(nodes)
        # @edges.merge!(edges)
        @graph_types[type][:nodes].merge!(nodes)
        @graph_types[type][:edges].merge!(edges)
      end
    else
      loader = loadermap[type].new({region: "us-east-1"})
      loader.connect_to_aws({region: "us-east-1", profile: profile})
      nodes, edges = loader.load_groups
      # @nodes.merge!(nodes)
      # @edges.merge!(edges)
      @graph_types[type][:nodes].merge!(nodes)
      @graph_types[type][:edges].merge!(edges)
    end
  end

  # def print_everything
  #   puts '-----------------------------------------'
  #   puts '-----------------------------------------'
  #   @nodes.values.each(&:print)
  #   puts '-----------------------------------------'
  #   puts '-----------------------------------------'
  #   @edges.values.each(&:print)
  #   puts '-----------------------------------------'
  #   puts '-----------------------------------------'
  # end

  def output_clustered(output_dir, graph_type)
    output_clustered_or_not(output_dir, true, graph_type)
  end

  def output_non_clustered(output_dir, graph_type)
    output_clustered_or_not(output_dir, false, graph_type)
  end

  private

  def output_clustered_or_not(output_dir, clustered, graph_type, cluster_type='vpc')
    writer = GraphvizWriter.new(@graph_types[graph_type][:nodes], @graph_types[graph_type][:edges], {use_subgraphs: clustered, subgraphs_of_type: cluster_type})
    output_subdir = clustered ? 'clustered' : 'non-clustered'
    writer.output_dir = File.join(output_dir, output_subdir)
    writer.use_subgraphs = clustered
    writer.output_individual_files_for_all_nodes
    writer.output_individual_files_for_all_edges
    writer.output_files_for_complete_graph
  end

end
