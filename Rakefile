require 'bundler/gem_tasks'
require 'cane/rake_task'
require 'tailor/rake_task'

desc "Run cane to check quality metrics"
Cane::RakeTask.new do |cane|
  cane.abc_exclude = %w(
    Jamie::RakeTasks#define
    Jamie::ThorTasks#define
    Jamie::CLI#pry_prompts
  )
  cane.style_exclude = %w(
    lib/vendor/hash_recursive_merge.rb
  )
  cane.doc_exclude = %w(
    lib/vendor/hash_recursive_merge.rb
  )
end

Tailor::RakeTask.new

task :default => [ :cane, :tailor ]
