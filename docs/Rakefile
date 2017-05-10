require "fileutils"
require "git"
require "logger"

$stdout.sync = true
logger = Logger.new(STDOUT)

task :default => ['assets:precompile']

desc "pubish to S3"
task :publish => [:pull, :push]

desc "git pull"
task :pull do
  git = Git.open(Dir.pwd, :log => logger)
  git.pull
end

task :push do
  # GO TO YOUR HOME BUCKET
end

desc "build assets"
namespace :assets do
  task :precompile do
    sh "bundle exec middleman build --clean --verbose"
  end
end
