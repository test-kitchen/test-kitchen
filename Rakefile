require "bundler/gem_tasks"

require "rake/testtask"
Rake::TestTask.new(:unit) do |t|
  t.libs.push "lib"
  t.test_files = FileList["spec/**/*_spec.rb"]
  t.verbose = true
end

namespace :unit do
  desc "Run each spec file in its own process to catch cross-file coupling"
  task :isolated do
    require "open3"

    specs = FileList["spec/**/*_spec.rb"].sort
    # Spec files are independent, and each one spends most of its time in
    # process startup, so run a few at a time.
    workers = (ENV["ISOLATED_WORKERS"] || 4).to_i
    failed = []

    specs.each_slice(workers) do |batch|
      batch.map do |spec|
        Thread.new do
          out, status = Open3.capture2e(
            Gem.ruby, "-Ilib", "-Ispec", spec
          )
          [spec, status.success?, out]
        end
      end.map(&:value).each do |spec, ok, out|
        puts(ok ? "  ok   #{spec}" : "  FAIL #{spec}\n#{out}")
        failed << spec unless ok
      end
    end

    unless failed.empty?
      abort "\n#{failed.length} of #{specs.length} spec files fail on their " \
            "own:\n  #{failed.join("\n  ")}\n\n" \
            "These pass in `rake unit` only because another spec file loads " \
            "something they need. Add the missing require."
    end

    puts "\nAll #{specs.length} spec files pass in isolation."
  end

  desc "Run the unit tests with coverage reporting"
  task :coverage do
    ENV["COVERAGE"] = "1"
    Rake::Task[:unit].invoke
  end
end

begin
  require "cucumber"
  require "cucumber/rake/task"
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = ["features", "-x", "--format progress", "--no-color", "--tags 'not @ignore'"]
  end
rescue LoadError
  puts "cucumber is not available. (sudo) gem install cucumber to run tests."
end

desc "Run all test suites"
task test: %i{unit features}

desc "Run the checks that must pass before a change is merged"
task verify: %i{unit unit:isolated style}

desc "Display LOC stats"
task :stats do
  puts "\n## Production Code Stats"
  sh "countloc -r lib/kitchen lib/kitchen.rb"
  puts "\n## Test Code Stats"
  sh "countloc -r spec features"
end

begin
  require "cookstyle/chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "cookstyle/chefstyle is not available. (sudo) gem install cookstyle to do style checking."
end

# Generation options live in .yardopts so that `yard` and `rake yard` agree.
begin
  require "yard"
  YARD::Rake::YardocTask.new(:yard) do |task|
    task.options += ["--no-cache"]
  end
rescue LoadError
  puts "yard is not available. (sudo) gem install yard to generate the docs."
end

desc "Run all quality tasks"
task quality: %i{style stats}

task default: %i{test quality}

namespace :docs do
  desc "Deploy docs"
  task :deploy do
    sh "cd docs && hugo"
    sh "aws --profile chef-cd s3 sync docs/public s3://test-kitchen-legacy.cd.chef.co --delete --acl public-read"
    sh "aws --profile chef-cd cloudfront create-invalidation --distribution-id EQD8MRW086SRT --paths '/*'"
  end
end
