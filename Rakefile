require 'bundler/gem_tasks'
require 'cane/rake_task'
require 'tailor/rake_task'

desc "Run cane to check quality metrics"
Cane::RakeTask.new do |cane|
  cane.abc_exclude = %w(
    Jamie::RakeTasks#define
    Jamie::Vagrant.define_vagrant_vm
  )
end

Tailor::RakeTask.new

task :default => [ :cane, :tailor ]
