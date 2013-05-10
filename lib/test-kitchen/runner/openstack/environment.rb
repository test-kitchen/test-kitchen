require 'test-kitchen/environment'
require 'json'
require 'fog'

module TestKitchen
  class Environment
    class Openstack < TestKitchen::Environment
      attr_reader :username, :password, :tenant, :auth_url, :region
      attr_reader :servers

      def initialize(conf={})
        super
        @username = conf[:username] || config.username
        @password = conf[:password] || config.password
        @tenant = conf[:tenant] || config.tenant
        @auth_url = conf[:auth_url] || config.auth_url
        @region = conf[:region] || config.region
        @servers = {}
        load
      end

      def create_server(platform_name, server_def)
        @servers[platform_name] ||=
          begin
            server = connection.servers.create({ :name => server_def[:instance_name],
                                                 :image_ref => server_def[:image_id],
                                                 :flavor_ref => server_def[:flavor_id],
                                                 :security_groups => server_def[:security_groups],
                                                 :key_name => server_def[:keyname]})
            server.wait_for { ready? }
            sleep(2) until tcp_test_ssh(server.public_ip_address['addr'])
            save
            server
          end

        # These won't persist on the fog objectso we have to set them every
        # time. :(
        @servers[platform_name].username = server_def[:ssh_user]
        if server_def[:ssh_key]
          @servers[platform_name].private_key_path = File.expand_path(server_def[:ssh_key])
        end
        @servers[platform_name]
      end

      def tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, '22')
        IO.select([tcp_socket], nil, nil, 5)
      rescue SocketError, Errno::ETIMEDOUT, Errno::EPERM,
        Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH
        false
      ensure
        tcp_socket && tcp_socket.close
      end

      def connection
        @connection ||= Fog::Compute.new(:provider => 'OpenStack',
                                         :openstack_username => username,
                                         :openstack_api_key => password,
                                         :openstack_auth_url => auth_url,
                                         :openstack_region => region,
                                         :openstack_tenant => tenant)
      end


      # The following functions all take a name of
      # of a VM in our enironment

      def status(name)
        if @servers.has_key?(name)
          @servers[name].state.to_s.downcase
        else
          "not created"
        end
      end

      def destroy(name)
        @servers[name].destroy if @servers.has_key?(name)
        @servers.delete(name)
        save
      end


      # Ideally we could use the #ssh and #scp functions on Fog's server '
      # object.  But these seem to be broken in the case of Openstack

      def ssh_options(name)
        if key = @servers[name].private_key_path
          {:keys => [key]}
        else
          {}
        end
      end

      def ssh(name)
        server = @servers[name]
        Fog::SSH.new(server.public_ip_address['addr'], server.username, ssh_options(name))
      end

      def scp(name)
        server = @servers[name]
        Fog::SCP.new(server.public_ip_address['addr'], server.username, ssh_options(name))
      end

      # GROSS: Global config as a class variable
      def config
        @@config
      end

      def self.config
        @@config
      end

      def self.config=(config)
        @@config = config
      end

      private

      # Store state in .openstack_state file,
      # allowing us to re-use already created VMs

      def state_file
        File.join(root_path, ".openstack_state")
      end

      def load
        if File.exists?(state_file)
          state = JSON.parse(File.read(state_file))
          state.each do |platform, id|
            @servers[platform] = connection.servers.get(id)
          end
        end
      end

      def save
        state = {}
        @servers.each {|k,s| state[k] = s.id}
        File.open(state_file, 'w') do |f|
          f.write(state.to_json)
        end
      end
    end
  end
end
