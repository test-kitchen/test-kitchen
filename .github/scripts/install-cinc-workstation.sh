#!/usr/bin/env bash
set -euo pipefail

curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -P cinc-workstation -v 26

if [[ "$(uname -s)" == "Darwin" && ! -x /opt/homebrew/bin/gmkdir ]]; then
  sudo ln -s /bin/mkdir /opt/homebrew/bin/gmkdir
fi

if [[ ! -x /opt/cinc-workstation/embedded/bin/cinc-cli ]]; then
  embedded_gem_dir=$(/opt/cinc-workstation/embedded/bin/ruby -e 'puts Gem.default_dir')
  sudo /opt/cinc-workstation/embedded/bin/gem install chef-cli \
    -v 6.1.30 \
    --install-dir "$embedded_gem_dir" \
    --bindir /opt/cinc-workstation/embedded/bin \
    --no-user-install \
    --clear-sources \
    --source https://rubygems.cinc.sh \
    --source https://rubygems.org \
    --no-document
fi

wrapper_dir="${RUNNER_TEMP}/cinc-workstation-bin"
mkdir -p "$wrapper_dir"

cat > "${wrapper_dir}/cinc-cli" <<'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail

while IFS='=' read -r name _; do
  case "$name" in
    BUNDLE*|BUNDLER*|GEM_HOME|GEM_PATH|RUBYLIB|RUBYOPT|RUBYGEMS_GEMDEPS)
      unset "$name"
      ;;
  esac
done < <(env)

for cli in \
  /opt/cinc-workstation/embedded/bin/cinc-cli \
  /opt/cinc-workstation/embedded/bin/chef-cli \
  /opt/cinc-workstation/embedded/bin/chef; do
  if [[ -x "$cli" ]]; then
    exec "$cli" "$@"
  fi
done

echo "Could not find a Cinc Workstation Policyfile CLI" >&2
exit 127
WRAPPER

chmod +x "${wrapper_dir}/cinc-cli"
printf '%s\n' "$wrapper_dir" >> "$GITHUB_PATH"
