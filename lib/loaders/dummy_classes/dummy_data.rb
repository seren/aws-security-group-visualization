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

    self.sg_data={
'auth-api' => ['80(auth-elb-prod),443(auth-elb-prod)','nexus','main-vpc'],
'auth-elb-prod' => ['','nexus','main-vpc'],
'auth-api-integration' => ['','nexus','main-vpc'],
'auth-api-preview' => ['','nexus','main-vpc'],
'auth-api-prod' => ['','nexus','main-vpc'],
'auth-api-sandbox' => ['','nexus','main-vpc'],
'auth-api-staging' => ['','nexus','main-vpc'],
'auth-api-test' => ['','nexus','main-vpc'],
'rds-auth-prod' => ['5432(auth-api-prod)','nexus','main-vpc'],
'rds-auth-non-prod' => ['5432(auth-api-sandbox),5432(auth-api-preview),5432(auth-api-staging),5432(auth-api-test),5432(auth-api-integration)','nexus','main-vpc'],
'jenkins-client' => ['22(jenkins-server)','nexus','main-vpc'],
'jenkins-server' => ['','nexus','main-vpc'],
'cms-elb-prod' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'cms-elb-staging' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'cms-master' => ['22(cms-slave)','nexus','main-vpc'],
'cms-slave' => ['','nexus','main-vpc'],
'cms-prod' => ['80(cms-elb-prod),443(cms-elb-prod)','nexus','main-vpc'],
'cms-staging' => ['80(cms-elb-staging),443(cms-elb-staging)','nexus','main-vpc'],
'cms-test' => ['','nexus','main-vpc'],
'cms-dev' => ['','nexus','main-vpc'],
'cms-all' => ['22(cms-all),80(vpn),433(vpn)','nexus','main-vpc'],
'rds-cms-non-prod' => ['3306(cms-staging),3306(cms-test),3306(cms-dev)','nexus','main-vpc'],
'rds-cms-prod' => ['3306(cms-prod)','nexus','main-vpc'],
'graph-app-elb-prod' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'graph-app-elb-staging' => ['','nexus','main-vpc'],
'graph-app-elb-preview' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'graph-app-integration' => ['','nexus','main-vpc'],
'graph-app-preview' => ['','nexus','main-vpc'],
'graph-app-prod' => ['80(graph-app-elb-prod),443(graph-app-elb-prod)','nexus','main-vpc'],
'graph-app-sandbox' => ['','nexus','main-vpc'],
'graph-app-staging' => ['80(graph-app-elb-staging),443(graph-app-elb-staging)','nexus','main-vpc'],
'graph-app-test' => ['','nexus','main-vpc'],
'rds-nexus-non-prod' => ['5432(graph-app-staging),5432(graph-app-preview),5432(graph-app-sandbox),5432(graph-app-test),5432(graph-app-integration)','nexus','main-vpc'],
'rds-nexus-prod' => ['5432(graph-app-prod)','nexus','main-vpc'],
'all-instances' => ['icmp-1(monitor),22(vpn),5666(monitor)','nexus','main-vpc'],
'chef-server' => ['80(all-instances),443(all-instances)','nexus','main-vpc'],
'globus-usage-stats-collection' => ['udp4810(0.0.0.0/0)','ops','ops-vpc'],
'logger' => ['1024(all-instances)','nexus','main-vpc'],
'monitor' => ['','nexus','main-vpc'],
'ossec-client' => ['udp1514(ossec-server)','nexus','main-vpc'],
'dw-analysis' => ['22(vpn)','ops','ops-vpc'],
'ossec-server' => ['udp1514(ossec-client),udp1514(transfer-ossec-client)','nexus','main-vpc'],
'vpn' => ['udp1194(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'public-web' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'publish-public-web' => ['80(0.0.0.0/0),443(0.0.0.0/0)','publish','publish-vpc'],
'publish-endpoint-public' => ['2811(0.0.0.0/0),50000-51000(0.0.0.0/0)','publish','publish-vpc'],
'publish-handle' => ['2641(0.0.0.0/0),udp2641(0.0.0.0/0),8000(0.0.0.0/0)','publish','publish-vpc'],
'publish-trial-and-demo-web' => ['','publish','publish-vpc'],
'publish-web' => ['','publish','publish-vpc'],
'rds-publication-handle-data' => ['5432(publish-handle)','nexus','main-vpc'],
'rds-publication-handle-production' => ['5432(publish-web)','nexus','main-vpc'],
'rds-publish-trial-and-demo' => ['5432(publish-trial-and-demo-web)','nexus','main-vpc'],
'rds-search-non-prod' => ['5432(search-api-staging),5432(search-api-test),5432(search-api-sandbox),5432(search-api-preview)','nexus','main-vpc'],
'rds-search-prod' => ['5432(search-api-prod)','nexus','main-vpc'],
'search-api-preview' => ['80(search-elb-preview),443(search-elb-preview)','nexus','main-vpc'],
'search-api-prod' => ['80(search-elb-prod),443(search-elb-prod)','nexus','main-vpc'],
'search-api-sandbox' => ['80(vpn),443(vpn)','nexus','main-vpc'],
'search-api-staging' => ['80(search-elb-staging),443(search-elb-staging)','nexus','main-vpc'],
'search-api-test' => ['80(vpn),443(vpn)','nexus','main-vpc'],
'search-elasticsearch-preview' => ['9200(search-api-preview),9200(search-elasticsearch-preview),9300(search-elasticsearch-preview)','nexus','main-vpc'],
'search-elasticsearch-prod' => ['9200(search-api-prod),9200(search-elasticsearch-prod),9300(search-elasticsearch-prod)','nexus','main-vpc'],
'search-elasticsearch-sandbox' => ['9200(search-api-sandbox),9200(search-elasticsearch-sandbox),9300(search-elasticsearch-sandbox)','nexus','main-vpc'],
'search-elasticsearch-staging' => ['9200(search-api-staging),9200(search-elasticsearch-staging),9300(search-elasticsearch-staging)','nexus','main-vpc'],
'search-elasticsearch-test' => ['9200(search-api-test),9200(search-elasticsearch-test),9300(search-elasticsearch-test)','nexus','main-vpc'],
'search-elb-prod' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'search-elb-preview' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'search-elb-staging' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'endpoints-public' => ['2811(0.0.0.0/0),50000-51000(0.0.0.0/0)','transfer','transfer-vpc'],
'endpoints-nonpublic' => ['2811(vpn),50000-51000(vpn)','transfer','transfer-vpc'],
'transfer-public-web' => ['80(0.0.0.0/0),443(0.0.0.0/0)','transfer','transfer-vpc'],
'rds-transfer-prod' => ['5432(transfer-prod)','transfer','transfer-vpc'],
'transfer-all-instances' => ['5666(transfer-monitor),22(vpn),2221(vpn),icmp-1(transfer-monitor),80(vpn),443(vpn)','transfer','transfer-vpc'],
'transfer-backend-prod' => ['','transfer','transfer-vpc'],
'transfer-backend-qa' => ['','transfer','transfer-vpc'],
'transfer-backend-sandbox' => ['','transfer','transfer-vpc'],
'transfer-backend-test' => ['','transfer','transfer-vpc'],
'transfer-backend-integration' => ['','transfer','transfer-vpc'],
'transfer-backend-preview' => ['','transfer','transfer-vpc'],
'transfer-cli-all' => ['22(vpn),80(vpn),443(vpn)','transfer','transfer-vpc'],
'transfer-cli-integration' => ['','transfer','transfer-vpc'],
'transfer-cli-preview' => ['22(0.0.0.0/0),80(0.0.0.0/0),443(0.0.0.0/0)','transfer','transfer-vpc'],
'transfer-cli-prod' => ['22(0.0.0.0/0),80(0.0.0.0/0),443(0.0.0.0/0)','transfer','transfer-vpc'],
'transfer-cli-qa' => ['','transfer','transfer-vpc'],
'transfer-cli-sandbox' => ['','transfer','transfer-vpc'],
'transfer-cli-test' => ['','transfer','transfer-vpc'],
'transfer-backend-all' => ['40000-51000(vpn)','transfer','transfer-vpc'],
'transfer-monitor' => ['','transfer','transfer-vpc'],
'transfer-ossec-client' => ['udp1514(ossec-server)','transfer','transfer-vpc'],
'transfer-prod' => ['','transfer','transfer-vpc'],
'transfer-relay-integration' => ['1024-65535(transfer-backend-integration),1024-65535(transfer-cli-integration),22(vpn),2223(vpn)','transfer','transfer-vpc'],
'transfer-relay-preview' => ['1024-65535(transfer-backend-preview),1024-65535(transfer-cli-preview),22(vpn),2223(0.0.0.0/0)','transfer','transfer-vpc'],
'transfer-relay-prod' => ['1024-65535(transfer-backend-prod),1024-65535(transfer-cli-prod),22(vpn),2223(0.0.0.0/0)','transfer','transfer-vpc'],
'transfer-relay-qa' => ['1024-65535(transfer-backend-qa),1024-65535(transfer-cli-qa),22(vpn),2223(vpn)','transfer','transfer-vpc'],
'transfer-relay-sandbox' => ['1024-65535(transfer-backend-sandbox),1024-65535(transfer-cli-sandbox),22(vpn),2223(vpn)','transfer','transfer-vpc'],
'transfer-relay-test' => ['1024-65535(transfer-backend-test),1024-65535(transfer-cli-test),22(vpn),2223(vpn)','transfer','transfer-vpc'],
'web-app' => ['443(auth-elb-prod)','nexus','main-vpc'],
'xsede-oidc-elb-prod' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'xsede-oidc-prod' => ['80(xsede-oidc-elb-prod),443(xsede-oidc-elb-prod)','nexus','main-vpc'],
'xsede-oidc-sandbox' => ['80(vpn),443(vpn)','nexus','main-vpc'],
'xsede-oidc-staging' => ['80(vpn),443(vpn)','nexus','main-vpc'],
'xsede-oidc-test' => ['80(vpn),443(vpn)','nexus','main-vpc'],
'dns-elb-prod' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'dns-prod' => ['80(dns-elb-prod),443(dns-elb-prod)','nexus','main-vpc'],
'dns-elb-sandbox' => ['80(0.0.0.0/0),443(0.0.0.0/0)','nexus','main-vpc'],
'dns-sandbox' => ['80(dns-elb-sandbox),443(dns-elb-sandbox)','nexus','main-vpc'],
}

# all
i_d_all={
'auth-integration1b' => ['all-instances,ossec-client,auth-api,auth-api-integration','nexus','main-vpc','instance'],
'auth1a-preview' => ['all-instances,ossec-client,auth-api,auth-api-preview','nexus','main-vpc','instance'],
'auth4b-production' => ['all-instances,ossec-client,auth-api,auth-api-prod','nexus','main-vpc','instance'],
'auth2b-production' => ['all-instances,ossec-client,auth-api,auth-api-prod','nexus','main-vpc','instance'],
'auth1b-sandbox' => ['all-instances,ossec-client,auth-api,auth-api-sandbox','nexus','main-vpc','instance'],
'auth1d-staging' => ['all-instances,ossec-client,auth-api,auth-api-staging','nexus','main-vpc','instance'],
'auth-nonprod-psql' => ['rds-auth-non-prod','nexus','main-vpc','rds'],
'auth1c-test' => ['all-instances,ossec-client,auth-api,auth-api-test','nexus','main-vpc','instance'],
'cms-dev1b' => ['all-instances,ossec-client,cms-all,cms-dev','nexus','main-vpc','instance'],
'cms-prod2b' => ['all-instances,ossec-client,cms-all,cms-prod','nexus','main-vpc','instance'],
'go-cms-staging-vpc' => ['public-web,cms-elb-staging','nexus','main-vpc','elb'],
'cms-staging1b' => ['all-instances,ossec-client,cms-all,cms-staging','nexus','main-vpc','instance'],
'cms-dev-test-and-staging-db' => ['rds-cms-non-prod','nexus','main-vpc','rds'],
'cms-test1a' => ['all-instances,ossec-client,cms-all,cms-test','nexus','main-vpc','instance'],
'dns1a-sandbox' => ['all-instances,ossec-client,dns-sandbox','nexus','main-vpc','elb'],
'dns-elb-sandbox' => ['dns-elb-sandbox','nexus','main-vpc','elb'],
'nexus1b-integration' => ['all-instances,ossec-client,graph-app-integration','nexus','main-vpc','instance'],
'nexus1a-preview' => ['all-instances,ossec-client,graph-app-preview','nexus','main-vpc','instance'],
'atlas-connect-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'bluewaters-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'ciconnect-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'computecanada-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'exeter-production' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'facebase-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'globusonline-eu-production' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'lbl-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'msu-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'nds-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'nersc-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'petrel-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'purdue-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'ucrcc-production' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'umich-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'uscms-connect-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'wrangler-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'nexus2a-production' => ['all-instances,ossec-client,graph-app-prod','nexus','main-vpc','instance'],
'nexus1c-sandbox' => ['all-instances,ossec-client,graph-app-sandbox','nexus','main-vpc','instance'],
'graph-api-staging' => ['public-web,graph-app-elb-staging','nexus','main-vpc','elb'],
'staging-globuscs-info' => ['public-web,graph-app-elb-staging','nexus','main-vpc','elb'],
'nexus1a-staging' => ['all-instances,ossec-client,graph-app-staging','nexus','main-vpc','instance'],
'nexus2a-staging' => ['all-instances,ossec-client,graph-app-staging','nexus','main-vpc','instance'],
'nexus-nonprod-psql' => ['rds-nexus-non-prod','nexus','main-vpc','rds'],
'nexus1b-test' => ['all-instances,ossec-client,graph-app-test','nexus','main-vpc','instance'],
'report-builder' => ['all-instances,ossec-client','nexus','main-vpc','instance'],
'monitor' => ['all-instances,ossec-client,monitor','nexus','main-vpc','instance'],
'search-api-preview' => ['public-web,search-elb-preview','nexus','main-vpc','elb'],
'search-api1a-preview' => ['all-instances,ossec-client,search-api-preview','nexus','main-vpc','instance'],
'search-api2a-preview' => ['all-instances,ossec-client,search-api-preview','nexus','main-vpc','instance'],
'search-es1a-preview' => ['all-instances,ossec-client,search-elasticsearch-preview','nexus','main-vpc','instance'],
'search-es2a-preview' => ['all-instances,ossec-client,search-elasticsearch-preview','nexus','main-vpc','instance'],
'search-es3a-preview' => ['all-instances,ossec-client,search-elasticsearch-preview','nexus','main-vpc','instance'],
'search-es3b-production' => ['all-instances,ossec-client,search-elasticsearch-prod','nexus','main-vpc','instance'],
'search-api1a-sandbox' => ['all-instances,ossec-client,search-api-sandbox','nexus','main-vpc','instance'],
'search-es1a-sandbox' => ['all-instances,ossec-client,search-elasticsearch-sandbox','nexus','main-vpc','instance'],
'search-api-staging' => ['public-web,search-elb-staging','nexus','main-vpc','elb'],
'search-api1a-staging' => ['all-instances,ossec-client,search-api-staging','nexus','main-vpc','instance'],
'search-api2a-staging' => ['all-instances,ossec-client,search-api-staging','nexus','main-vpc','instance'],
'search-es1b-staging' => ['all-instances,ossec-client,search-elasticsearch-staging','nexus','main-vpc','instance'],
'search-nonprod-psql' => ['rds-search-non-prod','nexus','main-vpc','rds'],
'search-api1a-test' => ['all-instances,ossec-client,search-api-test','nexus','main-vpc','instance'],
'search-es1a-test' => ['all-instances,ossec-client,search-elasticsearch-test','nexus','main-vpc','instance'],
'transfer-integration2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-integration','transfer','transfer-vpc','instance'],
'transfer-preview-ep2b' => ['transfer-ossec-client,transfer-all-instances,endpoints-public','transfer','transfer-vpc','instance'],
'transfer-prod-ep2c' => ['transfer-all-instances,endpoints-public','transfer','transfer-vpc','instance'],
'transfer-qa-ep1c' => ['transfer-ossec-client,transfer-all-instances,endpoints-nonpublic','transfer','transfer-vpc','instance'],
'transfer-qa-ep2c' => ['transfer-ossec-client,transfer-all-instances,endpoints-nonpublic','transfer','transfer-vpc','instance'],
'transfer-qa2-be' => ['transfer-ossec-client,transfer-all-instances,transfer-prod,transfer-backend-qa,transfer-backend-all','transfer','transfer-vpc','instance'],
'transfer-qa2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-qa','transfer','transfer-vpc','instance'],
'transfer-qa2-relay' => ['transfer-ossec-client,transfer-all-instances,transfer-relay-qa','transfer','transfer-vpc','instance'],
'transfer-sandbox2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-sandbox','transfer','transfer-vpc','instance'],
'transfer-test-ep1c' => ['transfer-ossec-client,transfer-all-instances,endpoints-nonpublic','transfer','transfer-vpc','instance'],
'transfer-test-ep2c' => ['transfer-ossec-client,transfer-all-instances,endpoints-nonpublic','transfer','transfer-vpc','instance'],
'transfer-test-ep3' => ['transfer-ossec-client,transfer-all-instances,endpoints-nonpublic','transfer','transfer-vpc','instance'],
'transfer-test2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-test','transfer','transfer-vpc','instance'],
'web-app' => ['all-instances,ossec-client,web-app','nexus','main-vpc','instance'],
'xsedeoidc1a-sandbox' => ['all-instances,ossec-client,xsede-oidc-sandbox','nexus','main-vpc','instance'],
'xsedeoidc1a-staging' => ['all-instances,ossec-client,xsede-oidc-staging','nexus','main-vpc','instance'],
'xsedeoidc1a-test' => ['all-instances,ossec-client,xsede-oidc-test','nexus','main-vpc','instance'],
'jenkins-client' => ['all-instances,ossec-client,jenkins-client','nexus','main-vpc','instance'],
'nexus-api-preview' => ['public-web,graph-app-elb-preview','nexus','main-vpc','elb'],
'ossec1c' => ['all-instances,ossec-server','nexus','main-vpc','instance'],
'cms-prod-edit1a' => ['all-instances,ossec-client,cms-all,cms-prod','nexus','main-vpc','instance'],
'cms-prod1b' => ['all-instances,ossec-client,cms-all,cms-prod','nexus','main-vpc','instance'],
'cms-prod-db' => ['rds-cms-prod','nexus','main-vpc','rds'],
'dns-elb-prod' => ['dns-elb-prod','nexus','main-vpc','elb'],
'dns1a-prod' => ['all-instances,ossec-client,dns-prod','nexus','main-vpc','instance'],
'dw-analysis' => ['all-instances,ossec-client,dw-analysis','ops','ops-vpc','instance'],
'globus-usage-stats' => ['all-instances,ossec-client,globus-usage-stats-collection','ops','ops-vpc','instance'],
'transfer-prod-ep1c' => ['transfer-all-instances,endpoints-public','transfer','transfer-vpc','instance'],
'xsede-oidc' => ['public-web,xsede-oidc-elb-prod','nexus','main-vpc','elb'],
'xsedeoidc1a-production' => ['all-instances,ossec-client,xsede-oidc-prod','nexus','main-vpc','instance'],
'auth-api-prod-b' => ['public-web,auth-elb-prod','nexus','main-vpc','elb'],
'auth3b-production' => ['all-instances,ossec-client,auth-api,auth-api-prod','nexus','main-vpc','instance'],
'auth1b-production' => ['all-instances,ossec-client,auth-api,auth-api-prod','nexus','main-vpc','instance'],
'auth-prod-psql' => ['rds-auth-prod','nexus','main-vpc','rds'],
'jenkins-prod' => ['all-instances,ossec-client,jenkins-server','nexus','main-vpc','instance'],
'go-cms-prod-vpc' => ['public-web,cms-elb-prod','nexus','main-vpc','elb'],
'customer-loadbalancers' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'nexus-api-prod-2' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'www-globusonline-org-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'nexus3a-production' => ['all-instances,ossec-client,graph-app-prod','nexus','main-vpc','instance'],
'nexus1a-production' => ['all-instances,ossec-client,graph-app-prod','nexus','main-vpc','instance'],
'nexus-prod' => ['rds-nexus-prod','nexus','main-vpc','rds'],
'vpn-production' => ['all-instances,ossec-client,vpn','nexus','main-vpc','instance'],
'chef-server' => ['all-instances,ossec-client,chef-server','nexus','main-vpc','instance'],
'logcollector-prod' => ['all-instances,ossec-client,logger','nexus','main-vpc','instance'],
'search-api-production' => ['public-web,search-elb-prod','nexus','main-vpc','elb'],
'search-api2a-production' => ['all-instances,ossec-client,search-api-prod','nexus','main-vpc','instance'],
'search-es2b-production' => ['all-instances,ossec-client,search-elasticsearch-prod','nexus','main-vpc','instance'],
'search-api1a-production' => ['all-instances,ossec-client,search-api-prod','nexus','main-vpc','instance'],
'search-es1b-production' => ['all-instances,ossec-client,search-elasticsearch-prod','nexus','main-vpc','instance'],
'search-prod-psql' => ['rds-search-prod','nexus','main-vpc','rds'],
'transfer-preview-ep1b' => ['transfer-ossec-client,transfer-all-instances,endpoints-public','transfer','transfer-vpc','instance'],
'transfer-preview2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-preview','transfer','transfer-vpc','instance'],
'transfer-prod2-be' => ['transfer-ossec-client,transfer-all-instances,transfer-prod,transfer-backend-prod,transfer-backend-all','transfer','transfer-vpc','instance'],
'transfer-prod2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-prod','transfer','transfer-vpc','instance'],
'transfer-prod2-relay' => ['transfer-ossec-client,transfer-all-instances,transfer-relay-prod','transfer','transfer-vpc','instance'],
'transfer-monitor-main' => ['transfer-all-instances,transfer-monitor','transfer','transfer-vpc','instance'],
'globusworld1b-production' => ['all-instances,ossec-client,public-web','nexus','main-vpc','instance'],
}

# # hipaa
i_d_hipaa={
'jenkins-client' => ['all-instances,ossec-client,jenkins-client','nexus','main-vpc','instance'],
'nexus-api-preview' => ['public-web,graph-app-elb-preview','nexus','main-vpc','elb'],
'ossec1c' => ['all-instances,ossec-server','nexus','main-vpc','instance'],
'auth-api-prod-b' => ['public-web,auth-elb-prod','nexus','main-vpc','elb'],
'auth3b-production' => ['all-instances,ossec-client,auth-api,auth-api-prod','nexus','main-vpc','instance'],
'auth1b-production' => ['all-instances,ossec-client,auth-api,auth-api-prod','nexus','main-vpc','instance'],
'auth-prod-psql' => ['rds-auth-prod','nexus','main-vpc','rds'],
'jenkins-prod' => ['all-instances,ossec-client,jenkins-server','nexus','main-vpc','instance'],
'go-cms-prod-vpc' => ['public-web,cms-elb-prod','nexus','main-vpc','elb'],
'customer-loadbalancers' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'nexus-api-prod-2' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'www-globusonline-org-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'nexus3a-production' => ['all-instances,ossec-client,graph-app-prod','nexus','main-vpc','instance'],
'nexus1a-production' => ['all-instances,ossec-client,graph-app-prod','nexus','main-vpc','instance'],
'nexus-prod' => ['rds-nexus-prod','nexus','main-vpc','rds'],
'vpn-production' => ['all-instances,ossec-client,vpn','nexus','main-vpc','instance'],
'chef-server' => ['all-instances,ossec-client,chef-server','nexus','main-vpc','instance'],
'logcollector-prod' => ['all-instances,ossec-client,logger','nexus','main-vpc','instance'],
'search-api-production' => ['public-web,search-elb-prod','nexus','main-vpc','elb'],
'search-api2a-production' => ['all-instances,ossec-client,search-api-prod','nexus','main-vpc','instance'],
'search-es2b-production' => ['all-instances,ossec-client,search-elasticsearch-prod','nexus','main-vpc','instance'],
'search-api1a-production' => ['all-instances,ossec-client,search-api-prod','nexus','main-vpc','instance'],
'search-es1b-production' => ['all-instances,ossec-client,search-elasticsearch-prod','nexus','main-vpc','instance'],
'search-prod-psql' => ['rds-search-prod','nexus','main-vpc','rds'],
'transfer-preview-ep1b' => ['transfer-ossec-client,transfer-all-instances,endpoints-public','transfer','transfer-vpc','instance'],
'transfer-preview2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-preview','transfer','transfer-vpc','instance'],
'transfer-prod2-be' => ['transfer-ossec-client,transfer-all-instances,transfer-prod,transfer-backend-prod,transfer-backend-all','transfer','transfer-vpc','instance'],
'transfer-prod2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-prod','transfer','transfer-vpc','instance'],
'transfer-prod2-relay' => ['transfer-ossec-client,transfer-all-instances,transfer-relay-prod','transfer','transfer-vpc','instance'],
'transfer-monitor-main' => ['transfer-all-instances,transfer-monitor','transfer','transfer-vpc','instance'],
'globusworld1b-production' => ['all-instances,ossec-client,public-web','nexus','main-vpc','instance'],
}

# simplified
i_d_simplified={
'cms-prod-edit1a' => ['all-instances,ossec-client,cms-all,cms-prod','nexus','main-vpc','instance'],
'cms-prod1b' => ['all-instances,ossec-client,cms-all,cms-prod','nexus','main-vpc','instance'],
'cms-prod-db' => ['rds-cms-prod','nexus','main-vpc','rds'],
'dns-elb-prod' => ['dns-elb-prod','nexus','main-vpc','elb'],
'dns1a-prod' => ['all-instances,ossec-client,dns-prod','nexus','main-vpc','instance'],
'dw-analysis' => ['all-instances,ossec-client,dw-analysis','ops','ops-vpc','instance'],
'globus-usage-stats' => ['all-instances,ossec-client,globus-usage-stats-collection','ops','ops-vpc','instance'],
'transfer-prod-ep1c' => ['transfer-all-instances,endpoints-public','transfer','transfer-vpc','instance'],
'xsede-oidc' => ['public-web,xsede-oidc-elb-prod','nexus','main-vpc','elb'],
'xsedeoidc1a-production' => ['all-instances,ossec-client,xsede-oidc-prod','nexus','main-vpc','instance'],
'auth-api-prod-b' => ['public-web,auth-elb-prod','nexus','main-vpc','elb'],
'auth3b-production' => ['all-instances,ossec-client,auth-api,auth-api-prod','nexus','main-vpc','instance'],
'auth1b-production' => ['all-instances,ossec-client,auth-api,auth-api-prod','nexus','main-vpc','instance'],
'auth-prod-psql' => ['rds-auth-prod','nexus','main-vpc','rds'],
'jenkins-prod' => ['all-instances,ossec-client,jenkins-server','nexus','main-vpc','instance'],
'go-cms-prod-vpc' => ['public-web,cms-elb-prod','nexus','main-vpc','elb'],
'customer-loadbalancers' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'nexus-api-prod-2' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'www-globusonline-org-prod' => ['public-web,graph-app-elb-prod','nexus','main-vpc','elb'],
'nexus3a-production' => ['all-instances,ossec-client,graph-app-prod','nexus','main-vpc','instance'],
'nexus1a-production' => ['all-instances,ossec-client,graph-app-prod','nexus','main-vpc','instance'],
'nexus-prod' => ['rds-nexus-prod','nexus','main-vpc','rds'],
'vpn-production' => ['all-instances,ossec-client,vpn','nexus','main-vpc','instance'],
'chef-server' => ['all-instances,ossec-client,chef-server','nexus','main-vpc','instance'],
'logcollector-prod' => ['all-instances,ossec-client,logger','nexus','main-vpc','instance'],
'search-api-production' => ['public-web,search-elb-prod','nexus','main-vpc','elb'],
'search-api2a-production' => ['all-instances,ossec-client,search-api-prod','nexus','main-vpc','instance'],
'search-es2b-production' => ['all-instances,ossec-client,search-elasticsearch-prod','nexus','main-vpc','instance'],
'search-api1a-production' => ['all-instances,ossec-client,search-api-prod','nexus','main-vpc','instance'],
'search-es1b-production' => ['all-instances,ossec-client,search-elasticsearch-prod','nexus','main-vpc','instance'],
'search-prod-psql' => ['rds-search-prod','nexus','main-vpc','rds'],
'transfer-preview-ep1b' => ['transfer-ossec-client,transfer-all-instances,endpoints-public','transfer','transfer-vpc','instance'],
'transfer-preview2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-preview','transfer','transfer-vpc','instance'],
'transfer-prod2-be' => ['transfer-ossec-client,transfer-all-instances,transfer-prod,transfer-backend-prod,transfer-backend-all','transfer','transfer-vpc','instance'],
'transfer-prod2-cli' => ['transfer-ossec-client,transfer-all-instances,transfer-cli-all,transfer-cli-prod','transfer','transfer-vpc','instance'],
'transfer-prod2-relay' => ['transfer-ossec-client,transfer-all-instances,transfer-relay-prod','transfer','transfer-vpc','instance'],
'transfer-monitor-main' => ['transfer-all-instances,transfer-monitor','transfer','transfer-vpc','instance'],
'globusworld1b-production' => ['all-instances,ossec-client,public-web','nexus','main-vpc','instance'],
}

self.instance_data=i_d_all
# self.instance_data=i_d_hipaa
# self.instance_data=i_d_simplified

    self.vpc_data = {
'main-vpc' => 'main-vpc',
'transfer-vpc' => 'transfer-vpc',
'ops-vpc' => 'ops-vpc',
    }


  end
end
