require 'bundler/gem_tasks'

begin
  require 'cane/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new do |cane|
    cane.abc_exclude = %w(
      Jamie::RakeTasks#define
      Jamie::Vagrant.define_vagrant_vm
    )
  end
rescue LoadError
  warn "cane not available, quality task not provided."
end
