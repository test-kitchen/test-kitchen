# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require_relative "../spec_helper"
require "open3"
require "tmpdir"
require "kitchen/box/cli"
require "kitchen/box/source"

describe Kitchen::Box::Catalog do
  before do
    @directory = Dir.mktmpdir
    @manifest = File.join(@directory, "manifest.json")
    @entry = {
      "name" => "bento/ubuntu-24.04", "version" => "202510.26.0",
      "provider" => "parallels", "architecture" => "arm64",
      "file" => "ubuntu.box", "bytes" => 3, "sha256" => Digest::SHA256.hexdigest("box")
    }
    File.write(File.join(@directory, "ubuntu.box"), "box")
  end

  after do
    FileUtils.remove_entry(@directory)
  end

  def catalog(*entries)
    File.write(@manifest, JSON.generate(entries))
    Kitchen::Box::Catalog.new(@manifest)
  end

  def resolve(source, **options)
    source.resolve(**{ name: @entry["name"], version: @entry["version"], provider: "parallels", architecture: "arm64" }.merge(options))
  end

  it "selects an exact name, version, provider and architecture" do
    alternatives = [
      @entry.merge("architecture" => "amd64", "file" => "other.box"),
      @entry.merge("provider" => "virtualbox", "file" => "other.box"),
      @entry.merge("version" => "202511.01.0", "file" => "other.box"),
    ]
    source = catalog(*alternatives, @entry)

    _(resolve(source)).must_equal File.realpath(File.join(@directory, "ubuntu.box"))
    _(source.entries(provider: "virtualbox").size).must_equal 1
    assert_raises(Kitchen::UserError) { resolve(source, version: "latest") }
  end

  it "rejects duplicate identities and paths that escape the manifest directory" do
    assert_raises(Kitchen::UserError) { catalog(@entry, @entry.dup) }
    assert_raises(Kitchen::UserError) { catalog(@entry.merge("file" => "../outside.box")) }

    File.symlink(File.expand_path(__FILE__), File.join(@directory, "outside.box"))
    source = catalog(@entry.merge("file" => "outside.box"))
    assert_raises(Kitchen::UserError) { resolve(source) }
  end

  it "rejects a digest mismatch even when the archive still has the expected size" do
    source = catalog(@entry)
    File.write(File.join(@directory, "ubuntu.box"), "bad")

    _(source.verify(source.entries.first)).must_match(/ubuntu\.box\z/)
    _(assert_raises(Kitchen::UserError) { resolve(source) }.message).must_match(/SHA-256 mismatch/)
  end

  it "rejects a missing, malformed or non-array manifest" do
    _(assert_raises(Kitchen::UserError) { Kitchen::Box::Catalog.new(nil) }.message).must_match(/Specify a box manifest/)
    File.write(@manifest, "{")
    _(assert_raises(Kitchen::UserError) { Kitchen::Box::Catalog.new(@manifest) }.message).must_match(/Cannot read box manifest/)
    File.write(@manifest, "{}")
    _(assert_raises(Kitchen::UserError) { Kitchen::Box::Catalog.new(@manifest) }.message).must_match(/must contain an array/)
  end

  it "rejects missing resolution fields and a file with the wrong size" do
    source = catalog(@entry)
    _(assert_raises(Kitchen::UserError) { resolve(source, version: nil) }.message).must_match(/requires a name/)
    File.write(File.join(@directory, "ubuntu.box"), "longer")
    _(assert_raises(Kitchen::UserError) { resolve(source) }.message).must_match(/Size mismatch/)
  end

  it "lists the provider selection in table and JSON output" do
    catalog(@entry, @entry.merge("provider" => "virtualbox", "file" => "other.box"))
    cli = Kitchen::Box::CLI
    with_env("KITCHEN_BOX_MANIFEST" => @manifest) do
      output, = capture_io { cli.start(%w{list --provider parallels}) }
      _(output).must_match(/Name +Version +Provider/)
      _(output).must_include "ubuntu.box"
      _(output).wont_include "other.box"
    end
    output, = capture_io { cli.start(["list", "--json", "--manifest", @manifest, "--provider", "virtualbox"]) }
    _(JSON.parse(output).map { |row| row.fetch("file") }).must_equal ["other.box"]
  end

  it "reports readable archives and missing archives in human-readable doctor output" do
    catalog(@entry, @entry.merge("architecture" => "amd64", "file" => "missing.box"))
    args = ["doctor", "--manifest", @manifest]
    output, = capture_io do
      _(assert_raises(SystemExit) { Kitchen::Box::CLI.start(args.dup) }.status).must_equal 1
    end
    _(output).must_match(/^OK +ubuntu\.box$/)
    _(output).must_match(/^FAIL +missing\.box .*Cannot read box/)

    output, = capture_io { Kitchen::Box::CLI.start(args + %w{--architecture arm64 --json}) }
    _(JSON.parse(output).first.fetch("checksum_verified")).must_equal false
    error = assert_raises(Kitchen::UserError) { Kitchen::Box::CLI.start(args + %w{--provider none}) }
    _(error.message).must_match(/No boxes match/)
  end

  it "reports failed checks as JSON and exits unsuccessfully outside a Kitchen project" do
    catalog(@entry, @entry.merge("architecture" => "amd64", "file" => "missing.box"))
    kitchen = File.expand_path("../../bin/kitchen", __dir__)
    output, stderr, status = Open3.capture3({ "KITCHEN_BOX_MANIFEST" => @manifest }, RbConfig.ruby, kitchen,
      "box", "doctor", "--checksum", "--json", chdir: @directory)

    _(status.exitstatus).must_equal 1
    _(stderr).must_be_empty
    _(JSON.parse(output).map { |row| row["checksum_verified"] }).must_equal [true, nil]
    _(JSON.parse(output).last.fetch("error")).must_match(/missing\.box/)
  end
end

describe Kitchen::Box::Cache do
  before do
    @directory = Dir.mktmpdir
    @source = File.join(@directory, "nas")
    FileUtils.mkdir_p(@source)
    @archive = File.join(@source, "ubuntu.box")
    @manifest = File.join(@source, "manifest.json")
    @entry = {
      "name" => "bento/ubuntu-24.04", "version" => "202510.26.0",
      "provider" => "virtualbox", "architecture" => "arm64",
      "file" => "ubuntu.box", "bytes" => 3, "sha256" => Digest::SHA256.hexdigest("box")
    }
    File.write(@archive, "box")
    File.write(@manifest, JSON.generate([@entry]))
    @catalog = Kitchen::Box::Catalog.new(@manifest)
    @cache = Kitchen::Box::Cache.new(File.join(@directory, "cache"))
  end

  after do
    FileUtils.remove_entry(@directory)
  end

  it "reuses the local copy and protects it until all instance leases are released" do
    token = SecureRandom.uuid
    other = SecureRandom.uuid
    path = @cache.fetch(@catalog, @entry, token)
    _(File.read(path)).must_equal "box"
    refute File.identical?(path, @archive)
    File.rename(@archive, File.join(@source, "offline.box"))
    _(@cache.fetch(@catalog, @entry, other)).must_equal path

    @cache.release(@entry.fetch("sha256"), token)
    plan = @cache.prune_plan
    _(plan.fetch(:protected).first.fetch(:path)).must_equal path
    _(plan.fetch(:reclaimable_bytes)).must_equal 0

    @cache.release(@entry.fetch("sha256"), other)
    plan = @cache.prune_plan
    _(plan.fetch(:removable).first.fetch(:path)).must_equal path
    _(plan.fetch(:reclaimable_bytes)).must_equal 3
    _(File.read(path)).must_equal "box"
    _(File.read(File.join(@source, "offline.box"))).must_equal "box"
  end

  it "keeps an entry with a cache operation in progress" do
    token = SecureRandom.uuid
    path = @cache.fetch(@catalog, @entry, token)
    @cache.release(@entry.fetch("sha256"), token)
    File.open(File.join(File.dirname(path), "lock"), "r+") do |lock|
      assert lock.flock(File::LOCK_EX)
      _(@cache.prune_plan.fetch(:protected).first.fetch(:reason)).must_equal "cache operation in progress"
    end
  end

  it "previews reclaimable bytes separately from leased archives and filters by provider" do
    token = SecureRandom.uuid
    @cache.fetch(@catalog, @entry, token)
    second = @entry.merge("provider" => "parallels", "file" => "second.box", "sha256" => Digest::SHA256.hexdigest("two"))
    File.write(File.join(@source, "second.box"), "two")
    @cache.fetch(@catalog, second, token)
    @cache.release(second.fetch("sha256"), token)
    args = ["prune", "--cache", @cache.root, "--dry-run"]

    output, = capture_io { Kitchen::Box::CLI.start(args.dup) }
    _(output).must_match(%r{^Keep +.*virtualbox/arm64.*in use})
    _(output).must_match(%r{^Would remove +.*parallels/arm64.*3 bytes})
    _(output).must_match(/1 archive\(s\), 3 bytes reclaimable/)

    output, = capture_io { Kitchen::Box::CLI.start(args + %w{--provider virtualbox --json}) }
    plan = JSON.parse(output)
    _(plan.fetch("removable")).must_be_empty
    _(plan.fetch("reclaimable_bytes")).must_equal 0
    _(plan.fetch("protected").first.fetch("provider")).must_equal "virtualbox"
    assert_raises(Kitchen::UserError) { Kitchen::Box::CLI.start(["prune", "--cache", @cache.root]) }
  end

  it "protects an archive with a hard link or a missing lease directory" do
    token = SecureRandom.uuid
    path = @cache.fetch(@catalog, @entry, token)
    @cache.release(@entry.fetch("sha256"), token)
    link = File.join(@directory, "still-in-use.box")
    File.link(path, link)
    _(@cache.prune_plan.fetch(:protected).first.fetch(:reason)).must_equal "archive has another hard link"

    File.unlink(link)
    Dir.rmdir(File.join(File.dirname(path), "leases"))
    _(@cache.prune_plan.fetch(:protected).first.fetch(:reason)).must_equal "lease directory unavailable"
    @cache.release(@entry.fetch("sha256"), token)
    assert File.file?(path)
  end

  it "ignores incomplete entries and rejects invalid lease references" do
    _(@cache.prune_plan.fetch(:removable)).must_be_empty
    @cache.release(@entry.fetch("sha256"), SecureRandom.uuid)
    assert_raises(Kitchen::UserError) { @cache.release(@entry.fetch("sha256"), "../bad") }
    assert_raises(Kitchen::UserError) { @cache.release("bad", SecureRandom.uuid) }

    path = @cache.fetch(@catalog, @entry, SecureRandom.uuid)
    FileUtils.mkdir_p(File.join(@cache.root, "unknown"))
    FileUtils.mkdir_p(File.join(@cache.root, "0" * 64))
    File.write(File.join(File.dirname(path), "metadata.json"), "null")
    _(@cache.prune_plan.fetch(:protected)).must_be_empty
    File.write(File.join(File.dirname(path), "metadata.json"), "{")
    _(@cache.prune_plan.fetch(:removable)).must_be_empty
  end

  it "restores a damaged cache copy from the verified source" do
    token = SecureRandom.uuid
    path = @cache.fetch(@catalog, @entry, token)
    File.write(path, "broken")
    _(@cache.fetch(@catalog, @entry, token)).must_equal path
    _(File.read(path)).must_equal "box"
  end

  it "rejects corrupt copies and keeps writes outside the manifest directory" do
    source_cache = Kitchen::Box::Cache.new(File.join(@source, "cache"))
    assert_raises(Kitchen::UserError) { source_cache.fetch(@catalog, @entry, SecureRandom.uuid) }
    refute File.exist?(source_cache.root)

    File.write(@archive, "bad")
    assert_raises(Kitchen::UserError) { @cache.fetch(@catalog, @entry, SecureRandom.uuid) }
    _(@cache.prune_plan.fetch(:removable)).must_be_empty
    _(File.read(@archive)).must_equal "bad"
  end

  it "reports a preview without changing either archive and requires --dry-run" do
    token = SecureRandom.uuid
    path = @cache.fetch(@catalog, @entry, token)
    @cache.release(@entry.fetch("sha256"), token)
    kitchen = File.expand_path("../../bin/kitchen", __dir__)
    output, stderr, status = Open3.capture3(RbConfig.ruby, kitchen, "box", "prune",
      "--cache", @cache.root, "--dry-run", "--json", chdir: @directory)

    assert status.success?, stderr
    _(JSON.parse(output).fetch("reclaimable_bytes")).must_equal 3
    _(File.read(path)).must_equal "box"
    _(File.read(@archive)).must_equal "box"
    _, _, status = Open3.capture3(RbConfig.ruby, kitchen, "box", "prune", "--cache", @cache.root, chdir: @directory)
    refute status.success?
  end
end

describe Kitchen::Box::Source do
  let(:driver_class) do
    Struct.new(:config) do
      include Kitchen::Box::Source
      public :box_source, :release_box_source
    end
  end

  it "resolves local paths without creating a cache lease" do
    Dir.mktmpdir do |directory|
      driver = driver_class.new({ box: "local.box", kitchen_root: directory })
      state = {}
      _(driver.box_source("parallels", state) { flunk "Unexpected checkpoint" }).must_equal File.join(directory, "local.box")
      driver.release_box_source(state)
      _(state).must_be_empty

      driver.config[:box] = { name: "bento/ubuntu-24.04" }
      _(assert_raises(Kitchen::ActionFailed) { driver.box_source("parallels", state) }.message).must_match(/exact version/)
    end
  end

  it "checkpoints a catalog lease before copying and reuses it until destroy" do
    Dir.mktmpdir do |directory|
      cache = Kitchen::Box::Cache.new(File.join(directory, "cache"))
      nas = File.join(directory, "nas")
      FileUtils.mkdir_p(nas)
      manifest = File.join(nas, "manifest.json")
      archive = File.join(nas, "ubuntu.box")
      File.write(archive, "box")
      entry = {
        "name" => "bento/ubuntu-24.04", "version" => "202510.26.0",
        "provider" => "parallels", "architecture" => Kitchen::Box::Catalog.host_architecture,
        "file" => "ubuntu.box", "bytes" => 3, "sha256" => Digest::SHA256.hexdigest("box")
      }
      File.write(manifest, JSON.generate([entry]))
      driver = driver_class.new({
        box: { name: entry.fetch("name"), version: entry.fetch("version") },
        kitchen_root: directory, box_manifest: "nas/manifest.json", box_cache: cache.root
      })
      state = {}

      path = driver.box_source("parallels", state) do
        _(state.fetch(:box_cache_lease).fetch(:digest)).must_equal entry.fetch("sha256")
        refute File.exist?(cache.root)
      end
      _(cache.prune_plan.fetch(:protected).first.fetch(:path)).must_equal path
      File.unlink(archive)
      _(driver.box_source("parallels", state) { flunk "Unexpected checkpoint" }).must_equal path

      driver.config[:box_cache] = File.join(directory, "another-cache")
      _(assert_raises(Kitchen::ActionFailed) { driver.box_source("parallels", state) }.message).must_match(/Run kitchen destroy/)
      driver.release_box_source(state)
      _(state).must_be_empty
      _(cache.prune_plan.fetch(:reclaimable_bytes)).must_equal 3
      _(assert_raises(Kitchen::ActionFailed) { driver.box_source("parallels", state) {} }.message).must_match(/Cannot read box/)
    end
  end
end
