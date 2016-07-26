# -*- encoding: utf-8 -*-

require "bundler/gem_tasks"

require "rake/testtask"
Rake::TestTask.new(:unit) do |t|
  t.libs.push "lib"
  t.test_files = FileList["spec/**/*_spec.rb"]
  t.verbose = true
end

begin
  require "cucumber"
  require "cucumber/rake/task"
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = ["features", "-x", "--format progress", "--no-color"]
  end
rescue LoadError
  puts "cucumber is not available. (sudo) gem install cucumber to run tests."
end

desc "Run all test suites"
task :test => [:unit, :features]

desc "Display LOC stats"
task :stats do
  puts "\n## Production Code Stats"
  sh "countloc -r lib/kitchen lib/kitchen.rb"
  puts "\n## Test Code Stats"
  sh "countloc -r spec features"
end

begin
  require "finstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "finstyle/rubocop is not available.  gem install finstyle to do style checking."
end

desc "Run all quality tasks"
task :quality => [:style, :stats]

begin
  require "yard"
  YARD::Rake::YardocTask.new
rescue LoadError
  puts "yard is not available. (sudo) gem install yard to generate yard documentation."
end

task :default => [:test, :quality]

begin
  require "github_changelog_generator/task"
  require "kitchen/version"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.future_release = "v#{Kitchen::VERSION}"
    config.enhancement_labels = "enhancement,Enhancement,New Feature,Feature,Improvement".split(",")
    config.bug_labels = "bug,Bug".split(",")
    config.exclude_labels = %w[Duplicate Question Discussion No_Changelog]
  end
rescue LoadError
  puts "github_changelog_generator is not available." \
       " gem install github_changelog_generator to generate changelogs"
end
