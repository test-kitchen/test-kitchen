require 'fileutils'

module TestKitchen

  class Scaffold

    def generate(output_dir)

      scaffold_file '.gitignore',
        <<-eos
          .bundle
          .cache
          .kitchen
          bin
        eos

      scaffold_file 'Gemfile',
        <<-eos
          gem 'test-kitchen'
        eos

      scaffold_file 'test/setup/README.md',
        <<-eos
          Place any cookbooks required for your testing under here.
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
