class Manager
  attr_reader :nodes, :edges
  attr_accessor :use_subgraphs

  def initialize(args = {})
    @use_subgraphs = args[:use_subgraphs] || false
    @opts = args
    @nodes = {}
    @edges = {}
  end

  def load(type=:manual)
    credentials = @opts
    loaders = case type
    when :security_groups
      [ AwsSecurityGroupLoader.new(credentials) ]
    when :instance_security_groups
      [ AwsEc2InstancesSecurityGroupLoader.new(credentials),
        AwsRdsInstancesSecurityGroupLoader.new(credentials) ]
    when :manual
      [ ManualAwsSecurityGroupLoader.new(credentials) ]
    when :instance_manual
      [ ManualAwsInstancesSecurityGroupLoader.new(credentials) ]
    end
    loaders.each do |loader|
      nodes, edges, clusteres = loader.load_groups
      @nodes += nodes
      @edges += edges
      @clusters += clusters
    end
  end

  def type_to_shape_mapping
    {'security_group' => '',
     'cidr' => '',
     'instance' => ''
    }
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

  def output_clustered(output_dir)
    output_clustered_or_not(output_dir, true)
  end

  def output_non_clustered(output_dir)
    output_clustered_or_not(output_dir, false)
  end

  def output_everything_graphs(output_dir)
    GraphvizWriter.new(@nodes, @edges, @clusters, {use_subgraphs: true, output_dir: File.join(output_dir, 'clustered')}).output_files_for_complete_graph
    GraphvizWriter.new(@nodes, @edges, @clusters, {use_subgraphs: false, output_dir: File.join(output_dir, 'non-clustered')}).output_files_for_complete_graph
  end

  private

  def output_clustered_or_not(output_dir, clustered)
    writer = GraphvizWriter.new(@nodes, @edges, @clusters, {use_subgraphs: clustered})
    output_subdir = clustered ? 'clustered' : 'non-clustered'
    writer.output_dir = File.join(output_dir, output_subdir)
    writer.use_subgraphs = clustered
    writer.output_individual_files_for_all_nodes
    writer.output_individual_files_for_all_edges
    writer.output_files_for_complete_graph
  end

end
