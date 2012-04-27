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
                  [Environment.current.projects.find{|p| p.name == options[:project]}]
                else
                  Environment.current.projects
                end

              projects.each do |project|
                project.vm = vm
                project.runtimes.each do |runtime|
                  execute_tests(project, runtime)
                end
              end
            end
          end
        end

        private

        def execute_tests(project, runtime=nil)
          project_root = "/vagrant/"

          command = "cd #{project_root}"
          case project.language
          when 'ruby'
            command << " && rvm use #{runtime}" if runtime
          when 'erlang'

          end
          command << " && #{project.script}"

          message = "Running tests for [#{project.name}]"
          message << " under [#{runtime}]" if runtime

          project.vm.ui.info(message, :color => :yellow)
          project.vm.channel.execute(command, :error_check => false) do |type, data|

            next if data =~ /stdin: is not a tty/

            if [:stderr, :stdout].include?(type)
              # Output the data with the proper color based on the stream.
              color = type == :stdout ? :green : :red

              project.vm.ui.info(data, :color => color, :prefix => false, :new_line => false)
            end
          end
        end

      end
    end
  end
end
