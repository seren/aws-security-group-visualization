class Ec2SecurityGroupEdge < Edge
  attr_accessor :tail_node, :head_node, :protocol, :port_start, :port_end, :props

  ICMP_TYPES = {
    '-1' => 'all',
    '0' => 'echo reply',
    '1' => 'unassigned',
    '2' => 'unassigned',
    '3' => 'destination unreachable',
    '4' => 'source quench',
    '5' => 'redirect',
    '6' => 'alternate host address',
    '7' => 'unassigned',
    '8' => 'echo',
    '9' => 'router advertisement',
    '10' => 'router selection',
    '11' => 'time exceeded',
    '12' => 'parameter problem',
    '13' => 'timestamp',
    '14' => 'timestamp reply',
    '15' => 'information request',
    '16' => 'information reply',
    '17' => 'address mask request',
    '18' => 'address mask reply',
    '19' => 'reserved (for security)',
    '20' => 'reserved (for robustness experiment)',
    '21' => 'reserved (for robustness experiment)',
    '22' => 'reserved (for robustness experiment)',
    '23' => 'reserved (for robustness experiment)',
    '24' => 'reserved (for robustness experiment)',
    '25' => 'reserved (for robustness experiment)',
    '26' => 'reserved (for robustness experiment)',
    '27' => 'reserved (for robustness experiment)',
    '28' => 'reserved (for robustness experiment)',
    '29' => 'reserved (for robustness experiment)',
    '30' => 'traceroute',
    '31' => 'datagram conversion error',
    '32' => 'mobile host redirect',
    '33' => 'ipv6 where-are-you',
    '34' => 'ipv6 i-am-here',
    '35' => 'mobile registration request',
    '36' => 'mobile registration reply',
    '37' => 'domain name request',
    '38' => 'domain name reply',
    '39' => 'skip',
    '40' => 'photuris'
  }.freeze

  def initialize(tail_node, head_node, props)
    self.port_start = props[:port_start].to_s || raise('edge props must contain :port_start')
    self.port_end = props[:port_end].to_s || raise('edge props must contain :port_end')
    self.protocol = props[:protocol].to_s || raise('edge props must contain :protocol')
    self.props = props
    super
  end

  # Combination of edge properties and node properties. Intended to uniquely id an edge
  def uid
    tn_uid = tail_node ? tail_node.uid+'-' : ''
    hn_uid = head_node ? head_node.uid+'-' : ''
    tn_vpcid = tail_node && tail_node.vpc_id&+'-' || ''
    hn_vpcid = head_node && head_node.vpc_id&+'-' || ''
    "tail-#{tn_vpcid}#{tn_uid}_head-#{hn_vpcid}#{hn_uid}_ports-#{port_start}-to-#{port_end}_proto-#{protocol || 'none'}"
  end

  # Like uid, but doesn't include the node uids
  # Intended to help find edges with identical properties
  def properties_uid
    "portstart-#{port_start}_portend-#{port_end}_proto-#{protocol}"
  end

  def port_and_proto_file_name
    'edges-' + sanitize_filename(properties_uid)
  end

  def url
    port_and_proto_file_name + '.html'
  end

  def label
    port_label
  end

  def port_label
    # Create edge label text from port info
    if protocol == 'all'
      protocol
    elsif protocol == 'icmp'
      'icmp ' + ICMP_TYPES[port_start]
    else
      port_combo = case port_start + '-' + port_end
                   when port_start + '-' + port_start then port_start
                   when '0-65535' then ''
                   when '1-65535' then ''
                   else port_start + '-' + port_end
                   end
      protocol + port_combo
    end
  end

  def to_s
    "#{uid}: #{tail_node.name} -> #{head_node.name}:#{label}"
  end

  def print
    puts "EDGE: \"#{uid}\""
    puts " #{tail_node.name} -> #{head_node.name}:#{label}"
    puts
  end
end
