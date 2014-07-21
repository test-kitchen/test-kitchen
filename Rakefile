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
  t.cucumber_opts = ["features", "-x", "--format progress"]
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
  task.options << "--display-cop-names"
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
