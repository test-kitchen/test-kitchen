#
# = Hash Recursive Merge
#
# Merges a Ruby Hash recursively, Also known as deep merge.
# Recursive version of Hash#merge and Hash#merge!.
#
# Category::    Ruby
# Package::     Hash
# Author::      Simone Carletti <weppos@weppos.net>
# Copyright::   2007-2008 The Authors
# License::     MIT License
# Link::        http://www.simonecarletti.com/
# Source::      http://gist.github.com/gists/6391/
#
module HashRecursiveMerge
  #
  # Recursive version of Hash#merge!
  #
  # Adds the contents of +other_hash+ to +hsh+,
  # merging entries in +hsh+ with duplicate keys with those from +other_hash+.
  #
  # Compared with Hash#merge!, this method supports nested hashes and
  # arrays.
  # When both +hsh+ and +other_hash+ contains an entry with the same key,
  # it merges and returns the values from both hashes.
  # If the values are arrays and +merge_arrays+ is true, underlying
  # arrays are also merged, as sets (guaranteeing unique values)
  #
  # @example
  #
  #    h1 = {"a" => 100, "b" => 200, "c" => {"c1" => 12, "c2" => 14}}
  #    h2 = {"b" => 254, "c" => {"c1" => 16, "c3" => 94}}
  #    h1.rmerge!(h2)   #=> {"a" => 100, "b" => 254, "c" => {"c1" => 16, "c2" => 14, "c3" => 94}}
  #
  # Simply using Hash#merge! would return
  #
  # @example
  #
  #    h1.merge!(h2)    #=> {"a" => 100, "b" = >254, "c" => {"c1" => 16, "c3" => 94}}
  #
  def rmerge!(other_hash, merge_arrays=false)
    merge!(other_hash) do |_key, oldval, newval|
      if oldval.class == self.class
        oldval.rmerge!(newval)
      elsif merge_arrays && oldval.is_a?(Array) && newval.is_a?(Array)
        oldval |= newval
      else
        newval
      end
    end
  end

  #
  # Recursive version of Hash#merge
  #
  # Compared with Hash#merge!, this method supports nested hashes.
  # When both +hsh+ and +other_hash+ contains an entry with the same key,
  # it merges and returns the values from both arrays.
  #
  # Compared with Hash#merge, this method provides a different approach
  # for merging nested hashes and arrays.
  # If the value of a given key is an Hash and both +other_hash+ and
  # +hsh+ includes the same key, the value is merged instead of being
  # replaced with +other_hash+ value.
  # If the value of a given key is an Array, +merge_arrays+ is true and
  # both +other_hash+ and +hsh+ include the same key, the underlying
  # arrays are also merged, as sets (guaranteeing unique values).
  #
  # @example
  #
  #    h1 = {"a" => 100, "b" => 200, "c" => {"c1" => 12, "c2" => 14}}
  #    h2 = {"b" => 254, "c" => {"c1" => 16, "c3" => 94}}
  #    h1.rmerge(h2)    #=> {"a" => 100, "b" => 254, "c" => {"c1" => 16, "c2" => 14, "c3" => 94}}
  #
  # Simply using Hash#merge would return
  #
  # @example
  #
  #    h1.merge(h2)     #=> {"a" => 100, "b" = >254, "c" => {"c1" => 16, "c3" => 94}}
  #
  def rmerge(other_hash, merge_arrays=false)
    r = {}
    merge(other_hash) do |key, oldval, newval|
      if oldval.class == self.class
        r[key] = oldval.rmerge(newval)
      elsif merge_arrays && oldval.is_a?(Array) && newval.is_a?(Array)
        r[key] = oldval | newval
      else
        newval
      end
    end
  end
end

class Hash
  include HashRecursiveMerge
end
