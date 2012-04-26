require 'optparse'

module TestKitchen
  module Vagrant
    module Command
      class Tk < ::Vagrant::Command::Base

        def execute
          options = {}
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant tk [vm-name] [-p project]"
            opts.separator ""
            opts.on("-p", "--project PROJECT", "Name of project to test.  If not provided all tests will be run.") do |p|
              options[:project] = p
            end
          end

          argv = parse_options(opts)
          return if !argv

          with_target_vms(argv) do |vm|
            if vm.created?

              projects = if options[:project]
                  {options[:project] => vm.config.tk.projects[options[:project]]}
                else
                  vm.config.tk.projects
                end

              projects.each_pair do |name, opts|

                opts['vm'] = vm
                runtime_versions = extract_runtime(opts)

                runtime_versions.each do |runtime|
                  execute_tests(name, opts, runtime)
                end

              end
            end
          end
        end

        private

        def execute_tests(project_name, opts, runtime=nil)

          project_root = "#{TestKitchen.test_root}/#{project_name}"

          command = "cd #{project_root}"
          case opts['language']
          when 'ruby'
            command << " && rvm use #{runtime}" if runtime
          when 'erlang'

          end
          command << " && #{opts['script'] || 'rspec spec'}"

          message = "Running tests for [#{project_name}]"
          message << " under [#{runtime}]" if runtime

          opts['vm'].ui.info(message, :color => :yellow)
          opts['vm'].channel.execute(command, :error_check => false) do |type, data|

            next if data =~ /stdin: is not a tty/

            if [:stderr, :stdout].include?(type)
              # Output the data with the proper color based on the stream.
              color = type == :stdout ? :green : :red

              opts['vm'].ui.info(data, :color => color, :prefix => false, :new_line => false)
            end
          end
        end

        def extract_runtime(opts)
          case opts['language']
          when 'ruby'
            opts['rvm'] || ['1.9.2']
          when 'erlang'
          end
        end
      end
    end
  end
end
