require "bundler/gem_tasks"
require 'cane/rake_task'
require 'tailor/rake_task'

desc "Run cane to check quality metrics"
Cane::RakeTask.new

Tailor::RakeTask.new

task :default => [ :cane, :tailor ]
