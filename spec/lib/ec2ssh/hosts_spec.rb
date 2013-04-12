require 'spec_helper'
require 'ec2ssh/hosts'

describe Ec2ssh::Hosts do
  before(:all) do
    Ec2ssh::Hosts.tap do |cls|
      cls.class_eval do
        def instances(region)
          [
            {:tag_set => [ { :key => 'Name', :value => 'db-01' } ], :dns_name => "ec2-1-1-1-1.#{region}.ec2.amazonaws.com" },
            {:tag_set => [ { :key => 'Name', :value => 'db-02' } ], :dns_name => "ec2-1-1-1-2.#{region}.ec2.amazonaws.com" },
            {:tag_set => [ { :key => 'Other', :value => 'db-03' } ], :dns_name => "ec2-1-1-1-3.#{region}.ec2.amazonaws.com" }
          ]
        end
      end
    end
  end
  
  let(:dotfile_config) do
    {
      'aws_keys' => [
        'key1' => {
          'access_key_id' => 'ACCESS_KEY_ID',
          'secret_access_key' => 'SECRET_ACCESS_KEY'
        }
      ],
      'append_region_to_host' => true
    }
  end
  
  describe Ec2ssh::Hosts, '#all' do
    it "returns all EC2 instances names with region appended and public DNS names" do
      dotfile = Ec2ssh::Dotfile.new(dotfile_config)
      hosts = Ec2ssh::Hosts.new(dotfile, 'key1').all
      
      hosts.first[:host].should eq('db-01.ap-northeast-1')
      hosts.first[:dns_name].should eq('ec2-1-1-1-1.ap-northeast-1.ec2.amazonaws.com')

      hosts.last[:host].should eq('db-02.ap-northeast-1')
      hosts.last[:dns_name].should eq('ec2-1-1-1-2.ap-northeast-1.ec2.amazonaws.com')
    end
    
    it "returns all EC2 instances names without region appended and public DNS names" do
      dotfile = Ec2ssh::Dotfile.new(dotfile_config.update('append_region_to_host' => false))
      hosts = Ec2ssh::Hosts.new(dotfile, 'key1').all
      
      hosts.first[:host].should eq('db-01')
      hosts.first[:dns_name].should eq('ec2-1-1-1-1.ap-northeast-1.ec2.amazonaws.com')

      hosts.last[:host].should eq('db-02')
      hosts.last[:dns_name].should eq('ec2-1-1-1-2.ap-northeast-1.ec2.amazonaws.com')
    end
    
  end
  
end
