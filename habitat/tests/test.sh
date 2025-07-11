#!/usr/bin/env bash

set -euo pipefail

export CHEF_LICENSE="accept-no-persist"
export HAB_LICENSE="accept-no-persist"
export HAB_NONINTERACTIVE="true"
export HAB_BLDR_CHANNEL="base-2025"

project_root="$(git rev-parse --show-toplevel)"
pkg_ident="$1"

# print error message followed by usage and exit
error () {
  local message="$1"

  echo -e "\nERROR: ${message}\n" >&2

  exit 1
}

[[ -n "$pkg_ident" ]] || error 'no hab package identity provided'

package_version=$(awk -F / '{print $3}' <<<"$pkg_ident")

cd "${project_root}"

echo "--- :mag_right: Testing ${pkg_ident} executables"
actual_version=$(hab pkg exec "${pkg_ident}" kitchen -- -v | sed -E 's/.*Version ([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
[[ "$package_version" = "$actual_version" ]] || error "test-kitchen is not the expected version. Expected '$package_version', got '$actual_version'"

echo "--- :Running rake"
hab pkg exec "${pkg_ident}" rake unit