# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require "fileutils" unless defined?(FileUtils)
require "tmpdir" unless defined?(Dir.mktmpdir)

module Kitchen
  module Box
    module SshBootstrap
      module_function

      def install(directory, runner:)
        path = instance_key(directory, runner)
        public_key = runner.call("/usr/bin/ssh-keygen", "-y", "-f", path).strip
        yield ["-c", INSTALL_KEY, "kitchen-key", INSECURE_RSA, INSECURE_ED25519, public_key.split.fetch(1), public_key]
        path
      end

      # Public key blobs from Vagrant's keys/vagrant.pub.{rsa,ed25519}.
      INSECURE_RSA = "AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==".freeze
      INSECURE_ED25519 = "AAAAC3NzaC1lZDI1NTE5AAAAIN1YdxBpNlzxDqfJyw/QKow1F+wvG9hXGoqiysfJOn5Y".freeze

      INSTALL_KEY = <<~'SH'.freeze
        set -eu
        umask 077
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        keys="$HOME/.ssh/authorized_keys"
        touch "$keys"
        temp=$(mktemp "$HOME/.ssh/kitchen-keys.XXXXXX")
        trap 'rm -f "$temp"' EXIT
        awk -v rsa="$1" -v ed="$2" -v new="$3" '
          /^[[:space:]]*#/ { print; next }
          {
            for (i = 2; i <= NF; i++) {
              if ($i == rsa || $i == ed || $i == new) next
            }
            print
          }
        ' "$keys" > "$temp"
        printf '%s\n' "$4" >> "$temp"
        mv -f "$temp" "$keys"
      SH

      def instance_key(directory, runner)
        FileUtils.mkdir_p(directory, mode: 0o700)
        path = File.join(directory, "ssh_key")
        return path if File.file?(path)

        Dir.mktmpdir("key-", directory) do |temporary|
          new_key = File.join(temporary, "ssh_key")
          runner.call("/usr/bin/ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", new_key)
          File.chmod(0o600, new_key)
          File.rename(new_key, path)
        end
        path
      end

    end
  end
end
