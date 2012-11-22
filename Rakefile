#!/usr/bin/env rake
require 'rubygems'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'cucumber/rake/task'

task :default => [:test, :features]

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['-f', 'pretty', 'features']
end
