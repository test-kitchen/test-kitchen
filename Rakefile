require 'bundler/gem_tasks'
require 'cane/rake_task'
require 'rake/testtask'
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

desc "Display LOC stats"
task :stats do
  puts "\n## Production Code Stats"
  sh "countloc -r lib/jamie lib/jamie.rb"
  puts "\n## Test Code Stats"
  sh "countloc -r spec"
end

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task :default => [ :test, :cane, :tailor, :stats ]
