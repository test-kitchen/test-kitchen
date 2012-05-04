module TestKitchen
  module Runner
    class LXC < Base

      NATTY = 'ubuntu-11.04'
      LXC_HOST = NATTY

      attr_reader :options
      attr_writer :nested_runner

      def initialize(env, options={})
        super
        @env, @options = env, options
      end

      def nested_runner
        @nested_runner ||=
          Runner.targets['vagrant'].new(@env, @options).tap do |vagrant|
            vagrant.platform = NATTY
          end
      end

      def provision
        nested_runner.provision
        nested_runner.with_target_vms(LXC_HOST) do |vm|
          with_platforms do |platform|
            nested_runner.execute_remote_command vm, "sudo test-kitchen-lxc provision '#{platform}'", 'Provisioning Linux Container'
          end
        end
      end

      def run_list
        ['test-kitchen::lxc']
      end

      def status
        puts 'status'
      end

      def destroy
        nested_runner.with_target_vms(LXC_HOST) do |vm|
          nested_runner.execute_remote_command vm,
            "sudo test-kitchen-lxc destroy '#{platform}'",
              'Destroying Linux Container'
        end
        # TODO: Need to collect the nested VM
        #nested_runner.destroy
      end

      def ssh
        # TODO: SSH to the correct host
        nested_runner.ssh
      end

      def with_platforms
        ['centos-6', 'natty'].each do |platform|
          yield platform
        end
      end

      def execute_remote_command(node, command, message=nil)
        nested_runner.with_target_vms(LXC_HOST) do |vm|
          nested_runner.execute_remote_command(vm, "sudo test-kitchen-lxc run '#{node}' '#{command}'", message)
        end
      end

    end
  end
end
