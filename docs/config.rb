###
# Page options, layouts, aliases and proxies
###

activate :syntax, :inline_theme => Rouge::Themes::Base16::Monokai.new
set :markdown_engine, :kramdown

# the only true server time
#Time.zone = "UTC"

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
page 'docs/*', layout: :sidebar

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration

###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do
  def link_classes(current_url, item_link)
    'is-active' if same_link?(current_url, item_link)
  end

  def same_link?(one, two)
    strip_trailing_slash(one) == strip_trailing_slash(two)
  end

  def strip_trailing_slash(str)
    str.end_with?('/') ? str[0..-2] : str
  end
end


activate :sprockets
activate :directory_indexes

# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end

###
# s3_sync configuration
###

AWS_BUCKET                      = 'kitchen.ci'
AWS_ACCESS_KEY                  = ENV['AWS_ACCESS_KEY']
AWS_SECRET                      = ENV['AWS_SECRET']

activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = AWS_BUCKET # The name of the S3 bucket you are targeting. This is globally unique.
  # s3_sync.region                     = 'us-east-1'     # The AWS region for your bucket. (S3 no longer requires this, dummy input?)
  s3_sync.aws_access_key_id          = AWS_ACCESS_KEY
  s3_sync.aws_secret_access_key      = AWS_SECRET
  s3_sync.delete                     = false # We delete stray files by default.
  # s3_sync.after_build                = false # We do not chain after the build step by default.
  # s3_sync.prefer_gzip                = true
  # s3_sync.path_style                 = true
  # s3_sync.reduced_redundancy_storage = false
  # s3_sync.acl                        = 'public-read'
  # s3_sync.encryption                 = false
  # s3_sync.prefix                     = ''
  # s3_sync.version_bucket             = false
end
