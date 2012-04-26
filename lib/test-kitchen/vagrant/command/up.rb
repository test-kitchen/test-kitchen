require 'optparse'

module TestKitchen
  module Vagrant
    module Command
      class Up < ::Vagrant::Command::Base

        def execute
          options = {}
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant up [vm-name] [-p project]"
            opts.separator ""
            opts.on("-p", "--project PROJECT", "Name of project to test.  If not provided all tests will be run.") do |p|
              options[:project] = p
            end
          end

          argv = parse_options(opts)

          with_target_vms(argv) do |vm|

            if options[:project]
              project = nil

              # remove other projects from chef-solo json
              vm.config.vm.provisioners.each do |p|
                if json = p.config.json
                  if json.key?('test-kitchen') && json['test-kitchen'].key?('projects')
                    if projects = json['test-kitchen']['projects'].keep_if {|k,v| k == options[:project]}
                      p.config.json['test-kitchen']['projects'] = projects
                      project = projects[options[:project]]
                    end
                  end
                end
              end

              # adjust the memory in the VM if required
              if project && project.key?('memory')
                vm.config.vm.customizations.each_with_index do |customization, index|
                  if mem_key_index = customization.index("--memory")
                    customization[mem_key_index + 1] = project['memory']
                    vm.config.vm.customizations[index] = customization
                  end
                end
              end
            end

            if vm.created?
              @logger.info("Booting: #{vm.name}")
              vm.ui.info I18n.t("vagrant.commands.up.vm_created")
              vm.start(options)
            else
              @logger.info("Creating: #{vm.name}")
              vm.up(options)
            end
          end
        end

      end
    end
  end
end
