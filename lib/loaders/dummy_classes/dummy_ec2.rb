class DummyEc2
  attr_accessor :security_groups, :instances, :vpcs

  def initialize(dummy_data)

    @security_groups = dummy_data.sg_data.map do |g_name, v|
      perms = v[0].split(',')
      account = v[1]
      vpc_id = v[2]
      sg = DummySecurityGroup.new
      sg.group_name = g_name
      sg.group_id = g_name
      sg.id = g_name
      sg.vpc_id = vpc_id
      sg.owner_id = account

      perms.each do |p|
        if p.size > 3
          perm = DummyIpPermission.new
          sg.ip_permissions << perm


          port,source = p.split('(')
          source=source.split(')').first
          if port.include?('icmp')
            perm.ip_protocol='icmp'
            port_start = port.split('p')[1]
          elsif port.include?('udp')
            port_start, port_end = port.split('-')
            port_start = port_start.split('p')[1]
            perm.ip_protocol='udp'
          else
            port_start, port_end = port.split('-')
            perm.ip_protocol='tcp'
          end

          port_end ||= port_start
          perm.from_port = port_start
          perm.to_port = port_end

          if source.include?('/')
            #cidr
            cidr = DummyIpRange.new
            perm.ip_ranges << cidr
            cidr.cidr_ip = source
          else
            #usergroup
            uigp = DummyUserIdGroupPair.new
            perm.user_id_group_pairs << uigp
            uigp.group_name = source
            uigp.group_id = source
            uigp.user_id = account
          end
        end
      end
      sg
    end


    @instances = dummy_data.instance_data.map do |i_name, v|
      security_groups = v[0].split(',').map do |sg_name|
        x = DummySecurityGroup.new
        x.group_id = sg_name
        x.group_name = sg_name
        x.id = sg_name
        x
      end
      account = v[1]
      vpc_id = v[2]
      type = v[3]
      i = DummyInstance.new
      i.id = i_name
      i.vpc_id = vpc_id
      i.security_groups = security_groups
      i.type = type
      i
    end

    @vpcs = dummy_data.vpc_data.map do |vpc_id, vpc_name|
      v = DummyVpc.new
      v.id = vpc_id
      v
    end
  end

end
