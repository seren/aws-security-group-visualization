# Date: 2017-09-06
# Author: Seren Thompson
#
# Description: Script that generates graphs and html pages with image maps for
# EC2 security groups, instances, and other relations


require 'rubygems'
require 'graphviz'
require 'set'
require 'optparse'
require 'ostruct'
require 'yaml'
require 'fileutils'
require 'pry'
require 'logger'
require 'aws-sdk'


require_relative 'lib/manager'

require_relative 'lib/cluster'

require_relative 'lib/edges/edge'
require_relative 'lib/edges/ec2_security_group_edge'
require_relative 'lib/edges/ec2_security_group_instance_edge'

require_relative 'lib/nodes/node'
require_relative 'lib/nodes/ec2_security_group_node'

require_relative 'lib/loaders/generic_loader'
require_relative 'lib/loaders/aws_security_group_loader'
require_relative 'lib/loaders/aws_ec2_instances_security_group_loader'
require_relative 'lib/loaders/aws_all_instances_security_group_loader'
require_relative 'lib/loaders/manual_aws_security_group_loader'
require_relative 'lib/loaders/manual_aws_instances_security_group_loader'

require_relative 'lib/writers/graphviz_writer'

Dir[File.dirname(__FILE__) + "/lib/loaders/dummy_classes/*.rb"].each {|file| require file }

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-o', '--output_dir DIRECTORY', 'Directory to write output files to. Default: html-output') { |o| options.output_dir = o || 'html-output' }
  opt.on('-p', '--profile PROFILE', 'Optional: AWS profile to use. Can be repeated to combine views of multiple profiles') { |o| options.profile_array ||= []; options.profile_array << o }
end.parse!

account = 'default'

graph_types = []
graph_types += [:instance_security_groups]
graph_types += [:security_groups]
# graph_types += [:manual]
# graph_types += [:instance_manual]
# graph_types += [:manual]

man = Manager.new()

graph_types.each do |graph_type|
    output_dir = File.join(Dir.pwd, '/', options.output_dir, '/', graph_type.to_s)

    # config yaml files contain :region and :profile (or :aws_access_key_id and :aws_access_key_id)
    man.opts = {region: 'us-east-1', profile_array: options.profile_array}
    man.load(graph_type)

    man.output_clustered(output_dir, graph_type)
    # man.output_non_clustered(output_dir, graph_type)
end
