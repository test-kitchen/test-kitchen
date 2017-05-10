###
# Page options, layouts, aliases and proxies
###

activate :syntax
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
