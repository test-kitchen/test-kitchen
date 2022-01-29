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

require "thor/util"

require_relative "../lazy_hash"
require_relative "../plugin_base"
require "benchmark" unless defined?(Benchmark)

module Kitchen
  module Driver
    # Legacy base class for a driver that uses SSH to communication with an
    # instance. This class has been updated to use the Instance's Transport to
    # issue commands and transfer files and no longer uses the `Kitchen:SSH`
    # class directly.
    #
    # **NOTE:** Authors of new Drivers are encouraged to inherit from
    # `Kitchen::Driver::Base` instead and existing Driver authors are
    # encouraged to update their Driver class to inherit from
    # `Kitchen::Driver::SSHBase`.
    #
    # A subclass must implement the following methods:
    # * #create(state)
    # * #destroy(state)
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    # @deprecated While all possible effort has been made to preserve the
    #   original behavior of this class, future improvements to the Driver,
    #   Transport, and Verifier subsystems may not be picked up in these
    #   Drivers. When legacy Driver::SSHBase support is removed, this class
    #   will no longer be available.
    class SSHBase < Kitchen::Plugin::Base
      include ShellOut
      include Configurable
      include Logging

      default_config :sudo, true
      default_config :port, 22
      # needs to be one less than the configured sshd_config MaxSessions
      default_config :max_ssh_sessions, 9

      # Creates a new Driver object using the provided configuration data
      # which will be merged with any default configuration.
      #
      # @param config [Hash] provided driver configuration
      def initialize(config = {})
        init_config(config)
      end

      # (see Base#create)
      def create(state) # rubocop:disable Lint/UnusedMethodArgument
        raise ClientError, "#{self.class}#create must be implemented"
      end

      # (see Base#converge)
      def converge(state) # rubocop:disable Metrics/AbcSize
        provisioner = instance.provisioner
        provisioner.create_sandbox
        sandbox_dirs = provisioner.sandbox_dirs

        instance.transport.connection(backcompat_merged_state(state)) do |conn|
          conn.execute(env_cmd(provisioner.install_command))
          conn.execute(env_cmd(provisioner.init_command))
          info("Transferring files to #{instance.to_str}")
          conn.upload(sandbox_dirs, provisioner[:root_path])
          debug("Transfer complete")
          conn.execute(env_cmd(provisioner.prepare_command))
          conn.execute(env_cmd(provisioner.run_command))
          info("Downloading files from #{instance.to_str}")
          provisioner[:downloads].to_h.each do |remotes, local|
            debug("Downloading #{Array(remotes).join(", ")} to #{local}")
            conn.download(remotes, local)
          end
          debug("Download complete")
        end
      rescue Kitchen::Transport::TransportFailed => ex
        raise ActionFailed, ex.message
      ensure
        instance.provisioner.cleanup_sandbox
      end

      # (see Base#setup)
      def setup(state)
        verifier = instance.verifier

        instance.transport.connection(backcompat_merged_state(state)) do |conn|
          conn.execute(env_cmd(verifier.install_command))
        end
      rescue Kitchen::Transport::TransportFailed => ex
        raise ActionFailed, ex.message
      end

      # (see Base#verify)
      def verify(state) # rubocop:disable Metrics/AbcSize
        verifier = instance.verifier
        verifier.create_sandbox
        sandbox_dirs = Util.list_directory(verifier.sandbox_path)

        instance.transport.connection(backcompat_merged_state(state)) do |conn|
          conn.execute(env_cmd(verifier.init_command))
          info("Transferring files to #{instance.to_str}")
          conn.upload(sandbox_dirs, verifier[:root_path])
          debug("Transfer complete")
          conn.execute(env_cmd(verifier.prepare_command))
          conn.execute(env_cmd(verifier.run_command))
        end
      rescue Kitchen::Transport::TransportFailed => ex
        raise ActionFailed, ex.message
      ensure
        instance.verifier.cleanup_sandbox
      end

      # (see Base#destroy)
      def destroy(state) # rubocop:disable Lint/UnusedMethodArgument
        raise ClientError, "#{self.class}#destroy must be implemented"
      end

      def legacy_state(state)
        backcompat_merged_state(state)
      end

      # Package an instance.
      #
      # (see Base#package)
      def package(state); end

      # (see Base#login_command)
      def login_command(state)
        instance.transport.connection(backcompat_merged_state(state))
          .login_command
      end

      # Executes an arbitrary command on an instance over an SSH connection.
      #
      # @param state [Hash] mutable instance and driver state
      # @param command [String] the command to be executed
      # @raise [ActionFailed] if the command could not be successfully completed
      def remote_command(state, command)
        instance.transport.connection(backcompat_merged_state(state)) do |conn|
          conn.execute(env_cmd(command))
        end
      end

      # **(Deprecated)** Executes a remote command over SSH.
      #
      # @param ssh_args [Array] ssh arguments
      # @param command [String] remote command to invoke
      # @deprecated This method should no longer be called directly and exists
      #   to support very old drivers. This will be removed in the future.
      def ssh(ssh_args, command)
        pseudo_state = { hostname: ssh_args[0], username: ssh_args[1] }
        pseudo_state.merge!(ssh_args[2])
        connection_state = backcompat_merged_state(pseudo_state)

        instance.transport.connection(connection_state) do |conn|
          conn.execute(env_cmd(command))
        end
      end

      # Performs whatever tests that may be required to ensure that this driver
      # will be able to function in the current environment. This may involve
      # checking for the presence of certain directories, software installed,
      # etc.
      #
      # @raise [UserError] if the driver will not be able to perform or if a
      #   documented dependency is missing from the system
      def verify_dependencies; end

      # Cache directory that a driver could implement to inform the provisioner
      # that it can leverage it internally
      #
      # @return path [String] a path of the cache directory
      def cache_directory; end

      private

      def backcompat_merged_state(state)
        driver_ssh_keys = %w{
          forward_agent hostname password port ssh_key username
        }.map(&:to_sym)
        config.select { |key, _| driver_ssh_keys.include?(key) }.rmerge(state)
      end

      # Builds arguments for constructing a `Kitchen::SSH` instance.
      #
      # @param state [Hash] state hash
      # @return [Array] SSH constructor arguments
      # @api private
      def build_ssh_args(state)
        combined = config.to_hash.merge(state)

        opts = {}
        opts[:user_known_hosts_file] = "/dev/null"
        opts[:verify_host_key] = false
        opts[:keys_only] = true if combined[:ssh_key]
        opts[:password] = combined[:password] if combined[:password]
        opts[:forward_agent] = combined[:forward_agent] if combined.key? :forward_agent
        opts[:port] = combined[:port] if combined[:port]
        opts[:keys] = Array(combined[:ssh_key]) if combined[:ssh_key]
        opts[:logger] = logger

        [combined[:hostname], combined[:username], opts]
      end

      # Adds http, https and ftp proxy environment variables to a command, if
      # set in configuration data or on local workstation.
      #
      # @param cmd [String] command string
      # @return [String] command string
      # @api private
      # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
      def env_cmd(cmd)
        return if cmd.nil?

        env = "env"
        http_proxy = config[:http_proxy] || ENV["http_proxy"] ||
          ENV["HTTP_PROXY"]
        https_proxy = config[:https_proxy] || ENV["https_proxy"] ||
          ENV["HTTPS_PROXY"]
        ftp_proxy = config[:ftp_proxy] || ENV["ftp_proxy"] ||
          ENV["FTP_PROXY"]
        no_proxy = if (!config[:http_proxy] && http_proxy) ||
            (!config[:https_proxy] && https_proxy) ||
            (!config[:ftp_proxy] && ftp_proxy)
                     ENV["no_proxy"] || ENV["NO_PROXY"]
                   end
        env << " http_proxy=#{http_proxy}"   if http_proxy
        env << " https_proxy=#{https_proxy}" if https_proxy
        env << " ftp_proxy=#{ftp_proxy}"     if ftp_proxy
        env << " no_proxy=#{no_proxy}"       if no_proxy

        env == "env" ? cmd : "#{env} #{cmd}"
      end

      # Executes a remote command over SSH.
      #
      # @param command [String] remove command to run
      # @param connection [Kitchen::SSH] an SSH connection
      # @raise [ActionFailed] if an exception occurs
      # @api private
      def run_remote(command, connection)
        return if command.nil?

        connection.exec(env_cmd(command))
      rescue SSHFailed, Net::SSH::Exception => ex
        raise ActionFailed, ex.message
      end

      # Transfers one or more local paths over SSH.
      #
      # @param locals [Array<String>] array of local paths
      # @param remote [String] remote destination path
      # @param connection [Kitchen::SSH] an SSH connection
      # @raise [ActionFailed] if an exception occurs
      # @api private
      def transfer_path(locals, remote, connection)
        return if locals.nil? || Array(locals).empty?

        info("Transferring files to #{instance.to_str}")
        debug("TIMING: scp asynch upload (Kitchen::Driver::SSHBase)")
        elapsed = Benchmark.measure do
          transfer_path_async(locals, remote, connection)
        end
        delta = Util.duration(elapsed.real)
        debug("TIMING: scp async upload (Kitchen::Driver::SSHBase) took #{delta}")
        debug("Transfer complete")
      rescue SSHFailed, Net::SSH::Exception => ex
        raise ActionFailed, ex.message
      end

      def transfer_path_async(locals, remote, connection)
        waits = []
        locals.map do |local|
          waits.push connection.upload_path(local, remote)
          waits.shift.wait while waits.length >= config[:max_ssh_sessions]
        end
        waits.each(&:wait)
      end

      # Blocks until a TCP socket is available where a remote SSH server
      # should be listening.
      #
      # @param hostname [String] remote SSH server host
      # @param username [String] SSH username (default: `nil`)
      # @param options [Hash] configuration hash (default: `{}`)
      # @api private
      def wait_for_sshd(hostname, username = nil, options = {})
        pseudo_state = { hostname: hostname }
        pseudo_state[:username] = username if username
        pseudo_state.merge!(options)

        instance.transport.connection(backcompat_merged_state(pseudo_state))
          .wait_until_ready
      end

      # Intercepts any bare #puts calls in subclasses and issues an INFO log
      # event instead.
      #
      # @param msg [String] message string
      def puts(msg)
        info(msg)
      end

      # Intercepts any bare #print calls in subclasses and issues an INFO log
      # event instead.
      #
      # @param msg [String] message string
      def print(msg)
        info(msg)
      end

      # Delegates to Kitchen::ShellOut.run_command, overriding some default
      # options:
      #
      # * `:use_sudo` defaults to the value of `config[:use_sudo]` in the
      #   Driver object
      # * `:log_subject` defaults to a String representation of the Driver's
      #   class name
      #
      # @see ShellOut#run_command
      def run_command(cmd, options = {})
        base_options = {
          use_sudo: config[:use_sudo],
          log_subject: Thor::Util.snake_case(self.class.to_s),
        }.merge(options)
        super(cmd, base_options)
      end

      # Returns the Busser object associated with the driver.
      #
      # @return [Busser] a busser
      def busser
        instance.verifier
      end
    end
  end
end
