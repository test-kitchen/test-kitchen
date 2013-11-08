###
# Globals
###
set :site_title, 'Test Kitchen'
set :site_url, 'http://test-kitchen.org'

# Remove .html extension from pages
activate :directory_indexes
set :trailing_slash, false

# Enable livereloading
require 'middleman-livereload'
activate :livereload

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Syntax
###
require 'middleman-syntax'
activate :syntax
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true,
               smartypants: true,
               no_intra_emphasis: true,
               tables: true,
               autolink: true,
               space_after_headers: true,
               with_toc_data: true

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

with_layout :docs do
  page '/docs/*'
end


# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# activate :livereload

# Methods defined in the helpers block are available in templates
helpers do
  def twitter(handle)
    handle.gsub!('@', '')
    link_to "@#{handle}", "https://twitter.com/#{handle}"
  end
end

set :css_dir,    'assets/stylesheets'
set :js_dir,     'assets/javascripts'
set :images_dir, 'assets/images'
set :fonts_dir,  'assets/fonts'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Compress PNGs after build
  require 'middleman-smusher'
  activate :smusher

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
