require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task :default => [ :test ]

unless RUBY_ENGINE == 'jruby'
  require 'cane/rake_task'
  require 'tailor/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new do |cane|
    cane.abc_exclude = %w(
      Jamie::RakeTasks#define
      Jamie::ThorTasks#define
      Jamie::CLI#pry_prompts
      Jamie::Instance#synchronize_or_call
    )
    cane.style_exclude = %w(
      lib/vendor/hash_recursive_merge.rb
    )
    cane.doc_exclude = %w(
      lib/vendor/hash_recursive_merge.rb
    )
  end

  Tailor::RakeTask.new do |task|
    task.file_set('bin/*', 'binaries')
    task.file_set('lib/**/*.rb', 'code') do |style|
      # FIXME: A few of these really LONG methods
      style.max_code_lines_in_method 210, level: :warn
    end
    task.file_set('spec/**/*.rb', 'tests')
  end

  Rake::Task[:default].enhance [ :cane, :tailor ]
end

desc "Display LOC stats"
task :stats do
  puts "\n## Production Code Stats"
  sh "countloc -r lib/jamie lib/jamie.rb"
  puts "\n## Test Code Stats"
  sh "countloc -r spec"
end

Rake::Task[:default].enhance [ :stats ]
