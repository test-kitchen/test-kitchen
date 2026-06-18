#!/usr/bin/env bash
set -euo pipefail

curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -P cinc-workstation -v 26
sudo /opt/cinc-workstation/embedded/bin/gem install chef-cli \
  -v 6.1.30 \
  --clear-sources \
  --source https://rubygems.cinc.sh \
  --no-document

wrapper_dir="${RUNNER_TEMP}/cinc-workstation-bin"
mkdir -p "$wrapper_dir"

cat > "${wrapper_dir}/cinc-cli" <<'WRAPPER'
#!/usr/bin/env bash
unset BUNDLE_BIN
unset BUNDLE_BIN_PATH
unset BUNDLE_GEMFILE
unset BUNDLE_PATH
unset BUNDLE_APP_CONFIG
unset BUNDLER_VERSION
unset BUNDLE_WITHOUT
unset RUBYGEMS_GEMDEPS
unset RUBYOPT
unset RUBYLIB
unset GEM_HOME
unset GEM_PATH
exec /opt/cinc-workstation/bin/cinc-cli "$@"
WRAPPER

chmod +x "${wrapper_dir}/cinc-cli"
printf '%s\n' "$wrapper_dir" >> "$GITHUB_PATH"
printf '%s\n' "/opt/cinc-workstation/bin" >> "$GITHUB_PATH"
