# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "net/https"
require "net/http"
require "socket"
require "uri"

PROXY_TIMEOUT = 2

module Kitchen

  module Driver

    # Base class for a driver that uses SSH to communication with an instance.
    # A subclass must implement the following methods:
    # * #create(state)
    # * #destroy(state)
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class SSHBase < Base

      default_config :sudo, true
      default_config :port, 22

      def create(state)
        raise ClientError, "#{self.class}#create must be implemented"
      end

      def converge(state)
        provisioner = new_provisioner

        Kitchen::SSH.new(*build_ssh_args(state)) do |conn|
          run_remote(provisioner.install_command, conn)
          run_remote(provisioner.init_command, conn)
          transfer_path(provisioner.create_sandbox, provisioner.home_path, conn)
          run_remote(provisioner.prepare_command, conn)
          run_remote(provisioner.run_command, conn)
        end
      ensure
        provisioner && provisioner.cleanup_sandbox
      end

      def setup(state)
        Kitchen::SSH.new(*build_ssh_args(state)) do |conn|
          run_remote(busser_setup_cmd, conn)
        end
      end

      def verify(state)
        Kitchen::SSH.new(*build_ssh_args(state)) do |conn|
          run_remote(busser_sync_cmd, conn)
          run_remote(busser_run_cmd, conn)
        end
      end

      def destroy(state)
        raise ClientError, "#{self.class}#destroy must be implemented"
      end

      def login_command(state)
        SSH.new(*build_ssh_args(state)).login_command
      end

      def ssh(ssh_args, command)
        Kitchen::SSH.new(*ssh_args) do |conn|
          run_remote(command, conn)
        end
      end

      protected

      def new_provisioner
        combined = config.dup
        combined[:log_level] = Util.from_logger_level(logger.level)
        Provisioner.for_plugin(combined[:provisioner], instance, combined)
      end

      def build_ssh_args(state)
        combined = config.to_hash.merge(state)

        opts = Hash.new
        opts[:user_known_hosts_file] = "/dev/null"
        opts[:paranoid] = false
        opts[:password] = combined[:password] if combined[:password]
        opts[:port] = combined[:port] if combined[:port]
        opts[:keys] = Array(combined[:ssh_key]) if combined[:ssh_key]
        opts[:logger] = logger

        [combined[:hostname], combined[:username], opts]
      end

      def get_local_web_proxy_address
        port_to_use = 8123 # polipo default... other options are squid default 3128
        port_to_use = config[:local_web_proxy_port] if config[:local_web_proxy_port]

        # TODO: perhaps return a tuple (i.e. don't format as string)?
        return "#{local_ip()}:#{port_to_use}"
      end

      # from http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
      # returns the host's non-private network IP address
      def local_ip
        # turn off reverse DNS resolution temporarily
        orig = Socket.do_not_reverse_lookup
        Socket.do_not_reverse_lookup = true

        UDPSocket.open do |s|
          # ip is for Google
          s.connect '64.233.187.99', 1
          s.addr.last
        end
      ensure
        # restore previous setting
        Socket.do_not_reverse_lookup = orig
      end

      def web_proxy_health_check(proxy_host, proxy_port, uri)
        proxy = Net::HTTP::Proxy(proxy_host, proxy_port)

        use_ssl = false
        verify_mode = nil
        if uri.scheme == 'https'
          use_ssl = true
          verify_mode = OpenSSL::SSL::VERIFY_PEER
        end

        begin
          http = proxy.start(
            uri.host,
            :use_ssl => use_ssl,
            :verify_mode => verify_mode)
          http.open_timeout = PROXY_TIMEOUT
          http.read_timeout = PROXY_TIMEOUT
          http_resp = http.get(uri.path)
        rescue Errno::ECONNREFUSED => e
          return false
        rescue Timeout::Error
          return false
        end

        if http_resp.code == '200'
          return true
        end
        return false
      end

      # tests http and https, assumes same server and port
      def http_and_https_proxy_working?(proxy_address)
        http_uri = URI('http://www.google.com/')
        https_uri = URI('https://www.google.com/')

        split_arr = proxy_address.split(':')
        proxy_host = split_arr[0]
        proxy_port = split_arr[1]

        puts "in http_and_https_proxy_working:"
        puts http_success = web_proxy_health_check(proxy_host, proxy_port, http_uri)
        puts https_success = web_proxy_health_check(proxy_host, proxy_port, https_uri)

        if http_success && https_success
          return true
        end
        return false
      end

      def env_cmd(cmd)
        if config[:use_local_web_proxy]
          puts "use_local_web_proxy: option is enabled."
          proxy_address = get_local_web_proxy_address()
          if http_and_https_proxy_working?(proxy_address)
            puts "use_local_web_proxy: proxy is healthy. using it."
            # TODO: hmm, bad to stomp on this config param?
            # - not clear that use_local_web_proxy will mess with http/https_proxy?
            config[:http_proxy] = "http://#{proxy_address}"
            config[:https_proxy] = "https://#{proxy_address}"
          else
            puts "use_local_web_proxy: proxy is not healthy. not using."
          end
        end

        env = "env"
        env << " http_proxy=#{config[:http_proxy]}"   if config[:http_proxy]
        env << " https_proxy=#{config[:https_proxy]}" if config[:https_proxy]

        env == "env" ? cmd : "#{env} #{cmd}"
      end

      def run_remote(command, connection)
        return if command.nil?

        connection.exec(env_cmd(command))
      rescue SSHFailed, Net::SSH::Exception => ex
        raise ActionFailed, ex.message
      end

      def transfer_path(local, remote, connection)
        return if local.nil?

        connection.upload_path!(local, remote)
      rescue SSHFailed, Net::SSH::Exception => ex
        raise ActionFailed, ex.message
      end

      def wait_for_sshd(hostname, username = nil, options = {})
        SSH.new(hostname, username, { :logger => logger }.merge(options)).wait
      end
    end
  end
end
