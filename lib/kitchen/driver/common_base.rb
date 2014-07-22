require 'kitchen/driver/ssh_base'
require 'kitchen/driver/winrm_base'
require 'kitchen/transport'


module Kitchen

  module Driver

    # Base class for a driver that uses SSH or WinRM to communication
    # with an instance.
    # Goal of this class is to provide a base driver which can be
    # used by other third party drivers to add Windows support by just
    # inheriting from this class instead of SSHBase.
    # Public API of SSHBase is provided except the deprecated ssh() method.
    # @author Serdar Sutay <serdar@getchef.com>
    class CommonBase < Base

      default_config :sudo, true
      default_config :port, 22
      default_config :transport, "SSH" # TODO: Documetation. Can also be "WinRM"

      # (see Base#create)
      def create(state) # rubocop:disable Lint/UnusedMethodArgument
        raise ClientError, "#{self.class}#create must be implemented"
      end

      # (see Base#converge)
      def converge(state)
        provisioner = instance.provisioner
        provisioner.create_sandbox
        sandbox_dirs = Dir.glob("#{provisioner.sandbox_path}/*")

        Kitchen::Transport.instantiate(config[:transport], state, self) do |conn|
          conn.run_remote(provisioner.install_command(config[:transport]))
          conn.run_remote(provisioner.init_command(config[:transport]))
          conn.transfer_path(sandbox_dirs, provisioner[:root_path])
          conn.run_remote(provisioner.prepare_command(config[:transport]))
          conn.run_remote(provisioner.run_command(config[:transport]))
        end
      ensure
        provisioner && provisioner.cleanup_sandbox
      end

      # (see Base#setup)
      def setup(state)
        Kitchen::Transport.instantiate(config[:transport], state, self) do |conn|
          conn.run_remote(busser.setup_cmd(config[:transport]))
        end
      end

      # (see Base#verify)
      def verify(state)
        Kitchen::Transport.instantiate(config[:transport], state, self) do |conn|
          conn.run_remote(busser.sync_cmd(config[:transport]))
          conn.run_remote(busser.run_cmd(config[:transport]))
        end
      end

      # (see Base#destroy)
      def destroy(state) # rubocop:disable Lint/UnusedMethodArgument
        raise ClientError, "#{self.class}#destroy must be implemented"
      end

      # (see Base#login_command)
      def login_command(state)
        Kitchen::Transport.instantiate(config[:transport], state, self).login_command
      end
    end
  end
end
