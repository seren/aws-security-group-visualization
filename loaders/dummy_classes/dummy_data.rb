class DummyData
  attr_accessor :sg_data, :instance_data, :vpc_data

  def initialize
    # Mock security groups
    self.sg_data={
      'monitor' => ['','main-account','main-vpc'],
      'server' => ['udp5555(monitor),8080(web-client),8443(web-client),8080(main-elb),8443(main-elb)','main-account','main-vpc'],
      'web-client' => ['','main-account','main-vpc'],
      'main-elb' => ['80(0.0.0.0/0),443(0.0.0.0/0)','main-account','main-vpc'],
      'backend' => ['1234(server)','other-account','other-vpc'],
      'backend-rds' => ['3306(backend)','other-account','other-vpc'],
    }

    # Mock instances
    self.instance_data = {
      'client1' => ['web-client','other-account','other-vpc','instance'],
      'client2' => ['web-client','main-account','main-vpc','instance'],
      'monitor' => ['monitor','main-account','main-vpc','instance'],
      'server1' => ['server','main-account','main-vpc','instance'],
      'backend-server' => ['backend','other-account','other-vpc','instance'],
      'main-elb' => ['main-elb','main-account','main-vpc','elb'],
      'backend-db' => ['backend-rds','other-account','other-vpc','rds'],
    }

    # Mock VPCs
    self.vpc_data = {
      'other-vpc' => 'other-vpc',
      'main-vpc' => 'main-vpc'
    }
  end
end
