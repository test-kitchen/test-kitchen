require_relative "../spec_helper"

require "vendor/hash_recursive_merge"

describe HashRecursiveMerge do
  it "recursively merges nested hashes with the new value taking precedence" do
    original = {
      top: "original",
      nested: { kept: true, replaced: "original" },
    }
    override = {
      top: "override",
      nested: { replaced: "override", added: true },
    }

    _(original.rmerge(override)).must_equal(
      top: "override",
      nested: { kept: true, replaced: "override", added: true }
    )
  end

  it "replaces a non-hash value instead of recursively merging it" do
    original = { value: "original" }
    override = { value: { nested: true } }

    _(original.rmerge(override)).must_equal(value: { nested: true })
  end

  it "does not mutate either source hash" do
    original = { nested: { original: true } }
    override = { nested: { override: true } }

    original.rmerge(override)

    _(original).must_equal(nested: { original: true })
    _(override).must_equal(nested: { override: true })
  end
end
