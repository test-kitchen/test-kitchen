require 'kitchen/driver/ec2'
require 'kitchen/provisioner/dummy'

describe Kitchen::Driver::Ec2 do

    let(:config) do
      {
        aws_ssh_key_id: 'larry',
        aws_access_key_id: 'secret',
        aws_secret_access_key: 'moarsecret',
        user_data: nil
      }
    end

    let(:state) do
      {}
    end

    let(:server) do
      double(
       :id => "123",
       :wait_for => nil,
       :dns_name => "server.example.com",
       :private_ip_address => '172.13.16.11',
       :public_ip_address => '213.225.123.134'
      )
    end

    let(:instance) do
      Kitchen::Instance.new(
        :platform => double(:name => "centos-6.4"),
        :suite => double(:name => "default"),
        :driver => driver,
        :provisioner => Kitchen::Provisioner::Dummy.new({}),
        :busser => double("busser"),
        :state_file => double("state_file")
      )
    end

    let(:driver) do
      Kitchen::Driver::Ec2.new(config)
    end

    let(:iam_creds) do
      {
        aws_access_key_id: 'iam_creds_access_key',
        aws_secret_access_key: 'iam_creds_secret_access_key',
        aws_session_token: 'iam_creds_session_token'
      }
    end

    before do
      instance
      allow(driver).to receive(:create_server).and_return(server)
      allow(driver).to receive(:wait_for_sshd)
    end

  context 'Interface is set in config' do

    it 'derives hostname from DNS when specified in the .kitchen.yml' do
      config[:interface] = 'dns'
      driver.create(state)
      expect(state[:hostname]).to eql('server.example.com')
    end

    it 'derives hostname from public interface when specified in the .kitchen.yml' do
      config[:interface] = 'public'
      driver.create(state)
      expect(state[:hostname]).to eql('213.225.123.134')
    end

    it 'derives hostname from private interface when specified in the .kitchen.yml' do
      config[:interface] = 'private'
      driver.create(state)
      expect(state[:hostname]).to eql('172.13.16.11')
    end

    it 'throws a nice exception if the config is bogus' do
      config[:interface] = 'I am an idiot'
      expect { driver.create(state) }.to raise_error(Kitchen::UserError, /^Invalid interface/)
    end

  end

  context 'Interface is derived automatically' do

    let(:server) do
      double(:id => "123",
             :wait_for => nil,
             :dns_name => nil,
             :private_ip_address => nil,
             :public_ip_address => nil)
    end

    it 'sets hostname to DNS value if DNS value exists' do
      allow(server).to receive(:dns_name).and_return('server.example.com')
      driver.create(state)
      expect(state[:hostname]).to eql('server.example.com')
    end

    it 'sets hostname to public value if public value exists' do
      allow(server).to receive(:public_ip_address).and_return('213.225.123.134')
      driver.create(state)

      expect(state[:hostname]).to eql('213.225.123.134')
    end

    it 'sets hostname to private value if private value exists' do
      allow(server).to receive(:private_ip_address).and_return('172.13.16.11')
      driver.create(state)
      expect(state[:hostname]).to eql('172.13.16.11')
    end

    it 'sets hostname to DNS if one or more Public/Private values are set' do
      allow(server).to receive(:dns_name).and_return('server.example.com')
      allow(server).to receive(:public_ip_address).and_return('213.225.123.134')
      allow(server).to receive(:private_ip_address).and_return('172.13.16.11')
      driver.create(state)
      expect(state[:hostname]).to eql('server.example.com')
    end

  end

  context 'user_data implementation is working' do

    it 'user_data is not defined' do
      driver.create(state)
      expect(state[:user_data]).to eql(nil)
    end

    it 'user_data is defined' do
      config[:user_data] = "#!/bin/bash\necho server > /tmp/hostname"
      driver.create(state)
      expect(config[:user_data]).to eql("#!/bin/bash\necho server > /tmp/hostname")
    end

  end

  context 'When #iam_creds returns values' do
    context 'but they should not be used' do
      context 'because :aws_access_key_id is not set via iam_creds' do
        it 'does not set config[:aws_session_token]' do
          config[:aws_access_key_id] = 'adifferentkey'
          allow(driver).to receive(:iam_creds).and_return(iam_creds)
          expect(driver.send(:config)[:aws_session_token]).to be_nil
        end
      end

      context 'because :aws_secret_key_id is not set via iam_creds' do
        it 'does not set config[:aws_session_token]' do
          config[:aws_secret_access_key] = 'adifferentsecret'
          allow(driver).to receive(:iam_creds).and_return(iam_creds)
          expect(driver.send(:config)[:aws_session_token]).to be_nil
        end
      end

      context 'because :aws_secret_key_id and :aws_access_key_id are set via iam_creds' do
        it 'does not set config[:aws_session_token]' do
          config[:aws_access_key_id] = 'adifferentkey'
          config[:aws_secret_access_key] = 'adifferentsecret'
          allow(driver).to receive(:iam_creds).and_return(iam_creds)
          expect(driver.send(:config)[:aws_session_token]).to be_nil
        end
      end
    end

    context 'and they should be used' do
      let(:config) do
        {
          aws_ssh_key_id: 'larry',
          user_data: nil
        }
      end

      before do
        allow(ENV).to receive(:[]).and_return(nil)
        allow(driver).to receive(:iam_creds).and_return(iam_creds)
      end

      it 'uses :aws_access_key_id from iam_creds' do
        expect(driver.send(:config)[:aws_access_key_id]).to eq(iam_creds[:aws_access_key_id])
      end

      it 'uses :aws_secret_key_id from iam_creds' do
        expect(driver.send(:config)[:aws_secret_key_id]).to eq(iam_creds[:aws_secret_key_id])
      end

      it 'uses :aws_session_token from iam_creds' do
        expect(driver.send(:config)[:aws_session_token]).to eq(iam_creds[:aws_session_token])
      end
    end
  end

  describe '#iam_creds' do
    context 'when a metadata service is available' do
      before do
        allow(Net::HTTP).to receive(:get).with(URI.parse('http://169.254.169.254')).and_return(true)
      end

      context 'and #fetch_credentials returns valid iam credentials' do
        it '#iam_creds retuns the iam credentials from fetch_credentials' do
          allow(driver).to receive(:fetch_credentials).and_return(iam_creds)
          expect(driver.send(:iam_creds)).to eq(iam_creds)
        end
      end

      context 'when #fetch_credentials fails with NoMethodError' do
        it 'returns an empty hash' do
          allow(driver).to receive(:fetch_credentials).and_raise(NoMethodError)
          expect(driver.iam_creds).to eq({})
        end
      end

      context 'when #fetch_credentials fails with StandardError' do
        it 'returns an empty hash' do
          allow(driver).to receive(:fetch_credentials).and_raise(::StandardError)
          expect(driver.iam_creds).to eq({})
        end
      end

      context 'when #fetch_credentials fails with Errno::EHOSTUNREACH' do
        it 'returns an empty hash' do
          allow(driver).to receive(:fetch_credentials).and_raise(Errno::EHOSTUNREACH)
          expect(driver.iam_creds).to eq({})
        end
      end

      context 'when #fetch_credentials fails with Timeout::Error' do
        it 'returns an empty hash' do
          allow(driver).to receive(:fetch_credentials).and_raise(Timeout::Error)
          expect(driver.iam_creds).to eq({})
        end
      end
    end

    context 'when a metadata service is not available' do
      it 'will not call #fetch_credentials' do
        allow(Net::HTTP).to receive(:get)
          .with(URI.parse('http://169.254.169.254')).and_return(false)
        expect(driver).to_not receive(:fetch_credentials)
      end
    end
  end

  describe '#block_device_mappings' do
    let(:connection) { double(Fog::Compute) }
    let(:image) { double('Image', :root_device_name => 'name') }
    before do
      expect(driver).to receive(:connection).and_return(connection)
    end

    context 'with bad config[:image_id]' do
      let(:config) do
        {
          aws_ssh_key_id: 'larry',
          aws_access_key_id: 'secret',
          aws_secret_access_key: 'moarsecret',
          image_id: 'foobar'
        }
      end

      it 'raises an error' do
        expect(connection).to receive_message_chain('images.get').with('foobar').and_return nil
        expect { driver.send(:block_device_mappings) }.to raise_error(/Could not find image/)
      end
    end

    context 'with good config[:image_id]' do
      before do
        expect(connection).to receive_message_chain('images.get')
          .with('ami-bf5021d6').and_return image
      end

      context 'no config is set' do
        it 'returns an empty default' do
          expect(driver.send(:block_device_mappings)).to eq([{
            "Ebs.VolumeType"=>"standard",
            "Ebs.VolumeSize"=>nil,
            "Ebs.DeleteOnTermination"=>nil,
            "Ebs.SnapshotId"=>nil,
            "DeviceName"=>nil,
            "VirtualName"=>nil
          }])
        end
      end

      context 'deprecated configs are set' do
        let(:config) do
          {
              aws_ssh_key_id: 'larry',
              aws_access_key_id: 'secret',
              aws_secret_access_key: 'moarsecret',
              ebs_volume_size: 100,
              ebs_delete_on_termination: false,
              ebs_device_name: 'name'
          }
        end

        it 'returns an empty default' do
          expect(driver.send(:block_device_mappings)).to eq([{
            "Ebs.VolumeType"=>"standard",
            "Ebs.VolumeSize"=>100,
            "Ebs.DeleteOnTermination"=>false,
            "Ebs.SnapshotId"=>nil,
            "DeviceName"=>'name',
            "VirtualName"=>nil
          }])
        end
      end

      context 'deprecated configs are set and so are new configs' do
        let(:block1) do
          {
            :ebs_volume_type => 'io1',
            :ebs_volume_size => 22,
            :ebs_delete_on_termination => true,
            :ebs_snapshot_id => 'snap-12345',
            :ebs_device_name => '/dev/sda1',
            :ebs_virtual_name => 'main'
          }
        end

        let(:config) do
          {
            aws_ssh_key_id: 'larry',
            aws_access_key_id: 'secret',
            aws_secret_access_key: 'moarsecret',
            ebs_volume_size: 100,
            ebs_delete_on_termination: false,
            ebs_device_name: 'name',
            block_device_mappings: [
              block1
            ]
          }
        end

        it 'returns the new configs' do
          expect(driver.send(:block_device_mappings)).to eq([{
            "Ebs.VolumeType"=>'io1',
            "Ebs.VolumeSize"=>22,
            "Ebs.DeleteOnTermination"=>true,
            "Ebs.SnapshotId"=>'snap-12345',
            "DeviceName"=>'/dev/sda1',
            "VirtualName"=>'main'
          }])
        end
      end
    end
  end

end
