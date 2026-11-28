# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require "bundler/setup"

# Cinc Workstation's policy CLI runs in its own Ruby installation.
Dir.chdir(__dir__)
Bundler.with_unbundled_env do
  load Gem.bin_path("test-kitchen", "kitchen")
end
