require 'fileutils'

module TestKitchen

  class Scaffold

    def generate(output_dir)

      scaffold_file '.gitignore',
        <<-eos
          .bundle
          bin
        eos

      scaffold_file 'Gemfile',
        <<-eos
          gem 'test-kitchen'

          # Add your other dependencies below:
          # gem 'cucumber'
          # gem 'librarian'
        eos

      scaffold_file 'Vagrantfile',
        <<-eos
          require 'test-kitchen'
          TestKitchen.setup
        eos

      scaffold_file 'config/projects.json',
        <<-eos
          {
            "projects": {
              "foo": {
                "language": "ruby",
                "rvm": ["1.9.2"],
                "repository": "https://github.com/you/your-repo.git",
                "revision": "master",
                "script": "bundle exec rspec spec",
                "memory": "256"
              }
            }
          }
        eos

      scaffold_file 'cookbooks/README.md',
        <<-eos
          Place any cookbooks required for your testing here.

          You can add recipes to the run_list by adding the following to your
          `Vagrantfile`.

              TestKitchen::Vagrant.configure :vagrant do |tk_config, vm_config|
                vm_config.vm.provision :chef_solo do |chef|
                  chef.add_recipe 'foo::default'
                end
              end
        eos
    end

    private

    def scaffold_file(path, content)
      FileUtils.mkdir_p(File.dirname(path))
      unless File.exists?(path)
        File.open(path, 'w') {|f| f.write(content.gsub(/^ {10}/, '')) }
      end
    end

  end

end
