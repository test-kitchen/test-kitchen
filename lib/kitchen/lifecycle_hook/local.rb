require_relative "base"
require_relative "../shell_out"
require_relative "../logging"

module Kitchen
  class LifecycleHook
    class Local < Base
      include ShellOut
      include Logging

      # Execute a specific local command hook.
      #
      # @return [void]
      def run
        state = state_file.read
        # set up empty user variable
        user = {}
        # Set up some environment variables with instance info.
        environment = {
          "KITCHEN_INSTANCE_NAME" => instance.name,
          "KITCHEN_SUITE_NAME" => instance.suite.name,
          "KITCHEN_PLATFORM_NAME" => instance.platform.name,
          "KITCHEN_INSTANCE_HOSTNAME" => state[:hostname].to_s,
        }
        # If the user specified env vars too, fix them up because symbol keys
        # make mixlib-shellout sad.
        hook[:environment]&.each do |k, v|
          environment[k.to_s] = v.to_s
        end

        # add user to user hash for later merging
        user[:user] = hook[:user] if hook[:user]

        # Default the cwd to the kitchen root and resolve a relative input cwd against that.
        cwd = if hook[:cwd]
                File.expand_path(hook[:cwd], config[:kitchen_root])
              else
                config[:kitchen_root]
              end
        # Build the options for mixlib-shellout.
        opts = {}.merge(user).merge(cwd: cwd, environment: environment)
        run_command(command, opts)
      end

      private

      # @return [String]
      def command
        hook.fetch(:local)
      end
    end
  end
end
