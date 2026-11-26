# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require "minitest/autorun"
require "open3"
require "tmpdir"
require_relative "../../lib/kitchen/box/catalog"
require_relative "../../lib/kitchen/box/cache"

describe Kitchen::Box::Catalog do
  before do
    @directory = Dir.mktmpdir
    @manifest = File.join(@directory, "manifest.json")
    @entry = {
      "name" => "bento/ubuntu-24.04", "version" => "202510.26.0",
      "provider" => "parallels", "architecture" => "arm64",
      "file" => "ubuntu.box", "bytes" => 3, "sha256" => Digest::SHA256.hexdigest("box"),
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
      "file" => "ubuntu.box", "bytes" => 3, "sha256" => Digest::SHA256.hexdigest("box"),
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
