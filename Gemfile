source 'https://rubygems.org'
gemspec

group :docs do
  gem 'middleman',            '~> 3.2'
  gem 'middleman-livereload', '~> 3.1'
  gem 'middleman-smusher',    '~> 3.0'
  gem 'middleman-syntax',     '~> 1.2'

  # Templating
  gem 'redcarpet', '~> 3.0'

  # For faster file watcher updates on Windows:
  gem 'wdm', '~> 0.1', platforms: [:mswin, :mingw]
end

group :guard do
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'guard-minitest', '~> 1.3'
  gem 'guard-cucumber', '~> 1.4'
end
