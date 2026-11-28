# frozen_string_literal: true

require "open3"
require "rbconfig"
require "yaml"

driver, platform, bootstrap_prefix = ARGV

def kitchen(*arguments)
  output, status = Open3.capture2e(RbConfig.ruby, File.join(__dir__, "run.rb"), *arguments)
  abort output unless status.success?

  output
end

provisioners = { "ansible" => "ansible_playbook", "cinc" => "cinc_infra", "puppet" => "puppet_apply" }
expected_names = provisioners.keys.map { |suite| "#{suite}-#{platform}" }
actual_names = kitchen("list", "--bare").lines.map(&:strip).sort
abort "Expected #{expected_names.inspect}, got #{actual_names.inspect}" unless actual_names == expected_names

diagnostics = kitchen("diagnose", "--loader", "--no-instances")
config = YAML.safe_load(diagnostics).fetch("loader").fetch("project_config").fetch("raw_data")
abort "Wrong driver for #{platform}" unless config.dig("driver", "name") == driver

verifier = config.fetch("verifier")
command = verifier.fetch("command")
expected_checks = [
  "systemctl is-enabled --quiet apache2",
  "systemctl is-active --quiet apache2",
  "http://127.0.0.1/",
  'test "$status" = 200',
]
abort "Missing remote Apache verifier" unless verifier.fetch("name") == "shell" && verifier.fetch("remote_exec")
abort "Incomplete Apache checks" unless expected_checks.all? { |check| command.include?(check) }

config.fetch("suites").each do |entry|
  suite = entry.fetch("name")
  provisioner = entry.fetch("provisioner")
  abort "Wrong provisioner for #{suite}" unless provisioner.fetch("name") == provisioners.fetch(suite)

  case suite
  when "cinc"
    abort "Missing Cinc idempotency check" unless provisioner.fetch("multiple_converge") == 2 && provisioner.fetch("enforce_idempotency")
  when "puppet", "ansible"
    package = suite == "puppet" ? "puppet-agent" : "ansible-core"
    bootstrap = "#{bootstrap_prefix}apt-get update -qq && #{bootstrap_prefix}env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq #{package}"
    hooks = entry.dig("lifecycle", "pre_converge")
    abort "Wrong bootstrap for #{suite}" unless hooks == [{ "remote" => bootstrap }]
    abort "Missing Ansible idempotency check" if suite == "ansible" && !provisioner.fetch("idempotency_test")
  end
end

puts "Kitchen loaded the Apache smoke suites for #{driver}"
