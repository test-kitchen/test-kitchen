desc 'Remove all files in the build directory'
task :clean do |t, args|
  # kill the old package dir
  rm_r 'build' rescue nil
end

desc 'Compile all files into the build directory'
task :build do
  puts '## Compiling static pages'
  status = system 'bundle exec middleman build'
  puts status ? 'Build successful.' : 'Build failed.'
end

desc 'Preview the site locally'
task :preview do
  system 'bundle exec middleman server'
end

desc 'Deploy to S3 and invalidate Cloudfront after a Git commit/push'
task :deploy do

  puts '## Deploy starting...'
  puts '## Syncing to S3...'
  system "bundle exec middleman s3_sync"
  puts '## Deploy complete.'
end

desc 'Publish (clean, build, deploy)'
task :publish => [:clean, :build, :deploy] do
end
