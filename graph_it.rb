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
require 'aws-sdk'
require 'logger'


require_relative 'manager'

require_relative 'edges/edge'
require_relative 'edges/ec2_security_group_edge'
require_relative 'edges/ec2_security_group_instance_edge'

require_relative 'nodes/node'
require_relative 'nodes/ec2_security_group_node'

require_relative 'loaders/generic_loader'
require_relative 'loaders/aws_security_group_loader'
require_relative 'loaders/aws_instances_security_group_loader'
require_relative 'loaders/manual_aws_security_group_loader'
require_relative 'loaders/manual_aws_instances_security_group_loader'

require_relative 'writers/graphviz_writer'

Dir[File.dirname(__FILE__) + "/loaders/dummy_classes/*.rb"].each {|file| require file }

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-o', '--output_dir DIRECTORY', 'Directory to write output files to. Default: html-output') { |o| options.output_dir = o }
  opt.on('-c', '--config_file CONFIG_FILE', 'File containing EC2 config options (region, profile or key/secret). Default: config/default.yml') { |o| options.config_file = o }
end.parse!

account = 'default'

graph_types = [:security_groups, :instance_security_groups]
graph_types = [:manual, :instance_manual]

options.output_dir ||= File.join(Dir.pwd, '/html-output')
graph_types.each do |type|

    # config yaml files contain :region and :profile (or :aws_access_key_id and :aws_access_key_id)
    options.config_file ||= "config/#{account}.yml"
    configuration = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)), options.config_file))

    man = Manager.new(configuration)
    man.load(type)

    man.output_clustered(options.output_dir)
    man.output_non_clustered(options.output_dir)
end
