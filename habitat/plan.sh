export HAB_BLDR_CHANNEL="LTS-2024"
_chef_client_ruby="core/ruby3_1"
pkg_name="chef-test-kitchen-enterprise"
pkg_origin="chef"
pkg_maintainer="The Chef Maintainers <humans@chef.io>"
pkg_description="The Chef Test Kitchen Enterprise"
pkg_license=('Apache-2.0')
pkg_bin_dirs=(
  bin
  vendor/bin
)
pkg_build_deps=(
  core/make
  core/bash
  core/gcc
)
pkg_deps=(
  $_chef_client_ruby
  core/coreutils
  core/git
)
pkg_svc_user=root

pkg_version() {
  cat "$SRC_PATH/VERSION"
}

do_before() {
  update_pkg_version
}

do_unpack() {
  mkdir -pv "$HAB_CACHE_SRC_PATH/$pkg_dirname"
  cp -RT "$PLAN_CONTEXT"/.. "$HAB_CACHE_SRC_PATH/$pkg_dirname/"
}

do_build() {
  echo $(pkg_path_for $_chef_client_ruby)
  export GEM_HOME="$pkg_prefix/vendor/gems"

  build_line "Setting GEM_PATH=$GEM_HOME"
  export GEM_PATH="$GEM_HOME"
  bundle config --local without integration deploy maintenance
  bundle config --local jobs 4
  bundle config --local retry 5
  bundle config --local silence_root_warning 1
  bundle install
  ruby ./post-bundle-install.rb
  gem build chef-test-kitchen-enterprise.gemspec
}

do_install() {
  export GEM_HOME="$pkg_prefix/vendor/gems"

  build_line "Setting GEM_PATH=$GEM_HOME"
  export GEM_PATH="$GEM_HOME"
  gem install chef-test-kitchen-enterprise-*.gem --no-document
  gem install chef-cli
  wrap_ruby_kitchen
  wrap_ruby_chef_cli
  set_runtime_env "GEM_PATH" "${pkg_prefix}/vendor/gems"
}

wrap_ruby_kitchen() {
  local bin="$pkg_prefix/bin/kitchen"
  local real_bin="$GEM_HOME/gems/chef-test-kitchen-enterprise-${pkg_version}/bin/kitchen"
  wrap_bin_with_ruby "$bin" "$real_bin"
}

wrap_ruby_chef_cli() {
  local bin="$pkg_prefix/bin/chef-cli"
  local real_bin="$GEM_HOME/bin/chef-cli"
  wrap_bin_with_ruby "$bin" "$real_bin"
}

wrap_bin_with_ruby() {
  local bin="$1"
  local real_bin="$2"
  build_line "Adding wrapper $bin to $real_bin"
  cat <<EOF > "$bin"
#!$(pkg_path_for core/bash)/bin/bash
set -e

# Set binary path that allows chef-test-kitchen-enterprise to use non-Hab pkg binaries
export PATH="/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:\$PATH"

# Set Ruby paths defined from 'do_setup_environment()'
export GEM_HOME="$pkg_prefix/vendor/gems"
export GEM_PATH="\$GEM_HOME"

exec $(pkg_path_for $_chef_client_ruby)/bin/ruby $real_bin \$@
EOF
  chmod -v 755 "$bin"
}

do_strip() {
  return 0
}
