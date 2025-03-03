export HAB_BLDR_CHANNEL="LTS-2024"
export HAB_REFRESH_CHANNEL="LTS-2024"
pkg_name="chef-test-kitchen-enterprise"
pkg_origin="chef"
pkg_maintainer="The Chef Maintainers <humans@chef.io>"
pkg_description="The Chef Test Kitchen Enterprise"
pkg_license=('Apache-2.0')
_chef_client_ruby="core/ruby3_1"
pkg_bin_dirs=(
  bin
)
pkg_build_deps=(
  core/make
  core/bash
  core/gcc
)
pkg_deps=(
  ${_chef_client_ruby}
  core/coreutils
  core/git
  chef/chef-cli/5.6.17/20250205114629
)
pkg_svc_user=root

pkg_version() {
  cat "$SRC_PATH/VERSION"
}

do_before() {
  update_pkg_version
}

do_setup_environment() {
  build_line 'Setting GEM_HOME="$pkg_prefix/vendor"'
  export GEM_HOME="$pkg_prefix/vendor"

  build_line "Setting GEM_PATH=$GEM_HOME"
  export GEM_PATH="$GEM_HOME"

  # these will be available at runtime; after the package is built and installed
  set_runtime_env "GEM_HOME" "$GEM_HOME"
  set_runtime_env -f "GEM_PATH" "$GEM_PATH"

  set_runtime_env "TKE_VERSION" "$pkg_version"
}

do_unpack() {
  mkdir -pv "$HAB_CACHE_SRC_PATH/$pkg_dirname"
  cp -RT "$PLAN_CONTEXT"/.. "$HAB_CACHE_SRC_PATH/$pkg_dirname/"
}

do_build() {
  export GEM_HOME="$pkg_prefix/vendor"

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
  # The bin/kitchen is the executable that will 
  cp "habitat/bin/kitchen" "$pkg_prefix/bin"
  chmod 755 "$pkg_prefix/bin/kitchen"

  export GEM_HOME="$pkg_prefix/vendor"
  build_line "Setting GEM_PATH=$GEM_HOME"
  export GEM_PATH="$GEM_HOME"
  gem install chef-test-kitchen-enterprise-*.gem --no-document
}

do_strip() {
  return 0
}
