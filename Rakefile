# -*- encoding: utf-8 -*-

require "bundler/gem_tasks"

require "rake/testtask"
Rake::TestTask.new(:unit) do |t|
  t.libs.push "lib"
  t.test_files = FileList["spec/**/*_spec.rb"]
  t.verbose = true
end

require "cucumber"
require "cucumber/rake/task"
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ["features", "-x", "--format progress", "--no-color"]
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

require "finstyle"
require "rubocop/rake_task"
RuboCop::RakeTask.new(:style) do |task|
  task.options += ["--display-cop-names", "--no-color"]
end

if RUBY_ENGINE != "jruby"
  require "cane/rake_task"
  desc "Run cane to check quality metrics"
  Cane::RakeTask.new do |cane|
    cane.canefile = "./.cane"
  end

  desc "Run all quality tasks"
  task :quality => [:cane, :style, :stats]
else
  desc "Run all quality tasks"
  task :quality => [:style, :stats]
end

require "yard"
YARD::Rake::YardocTask.new

task :default => [:test, :quality]

task :deploy_over_dk do
  if RUBY_PLATFORM =~ /mswin|mingw|windows/
    dk_path = File.join(ENV["SYSTEMDRIVE"], "opscode", "chefdk")
  else
    dk_path = "/opt/chefdk"
  end

  dk_app_path = File.join(dk_path, %w[embedded apps test-kitchen])
  FileUtils.copy_entry(File.dirname(__FILE__), dk_app_path)
  git_dir = File.join(dk_app_path, ".git")
  FileUtils.rm_rf(git_dir) if Dir.exist?(git_dir)
end

task :dk_install => [:deploy_over_dk, :install]

require 'github_changelog_generator/task'

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.future_release = Kitchen::VERSION
  config.enhancement_labels = "enhancement,Enhancement,New Feature,Feature".split(",")
  config.bug_labels = "bug,Bug,Improvement".split(",")
  config.exclude_labels = "duplicate,question,invalid,wontfix,no_changelog,Exclude From Changelog,Question,Upstream Bug,Discussion".split(",")
end
