require 'bundler/gem_tasks'
require 'rake/testtask'
require 'cucumber'
require 'cucumber/rake/task'

Rake::TestTask.new(:unit) do |t|
  t.libs.push "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['features', '-x', '--format progress']
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

unless RUBY_ENGINE == 'jruby'
  require 'cane/rake_task'
  require 'tailor/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new do |cane|
    cane.abc_max = 20
    cane.abc_exclude = %w(
      Kitchen::RakeTasks#define
      Kitchen::ThorTasks#define
      Kitchen::CLI#pry_prompts
      Kitchen::CLI#debug_instance
      Kitchen::Instance#synchronize_or_call
      Kitchen::Driver::SSHBase#converge
    )
    cane.style_exclude = %w(
      lib/vendor/hash_recursive_merge.rb
    )
    cane.doc_exclude = %w(
      lib/vendor/hash_recursive_merge.rb
    )
    cane.style_measure = 160
  end

  Tailor::RakeTask.new do |task|
    task.file_set('bin/*', 'binaries')
    task.file_set('lib/**/*.rb', 'code') do |style|
      # TODO: Tailor is confused thinking `module Kitchen` is a class. Until
      # the classes are split in seperate files, let's punt on this
      style.max_code_lines_in_class 1550, level: :warn
      # NOTE: Kitchen::InitGenerator.default_yaml is over the default 30 lines
      # and produces a warning. Since most of it is increasing readability of
      # the data structure, allowing it here to prevent it from growing
      style.max_code_lines_in_method 34
      style.max_line_length 80, level: :warn
      style.max_line_length 160, level: :error
    end
    task.file_set('spec/**/*.rb', 'tests') do |style|
      # allow vertical alignment of `let(:foo) { block }` blocks
      style.spaces_before_lbrace 1, level: :off
    end
    task.file_set('spec/kitchen/data_munger_spec.rb', 'tests') do |style|
      # allow data formatting in DataMunger
      style.indentation_spaces 2, level: :off
      # allow far larger spec file to cover all data input cases as possible
      style.max_code_lines_in_class 600, level: :off
    end
  end

  desc "Run all quality tasks"
  task :quality => [:cane, :stats]
else
  desc "Run all quality tasks"
  task :quality => [:stats]
end

task :default => [:test, :quality]
