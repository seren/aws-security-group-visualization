# tail = src
# head = dst

class ManualAwsSecurityGroupLoader < AwsSecurityGroupLoader

  # Stub so we don't try to actually connect
  def connect_to_aws(args)
    dummy_data = DummyData.new
    DummyEc2.new(dummy_data)
  end

  # def vpc_name(vpc_id)
  #   'dummy_vpc'
  # end


end
