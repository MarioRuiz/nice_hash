# frozen_string_literal: true

require "nice_hash"

RSpec.describe "NiceHash missing coverage" do
  describe "transtring" do
    it "translates nested hash to dot-separated string" do
      expect(NiceHash.transtring({ uno: { dos: :tres } })).to eq "uno.dos.tres"
    end

    it "handles single-level hash" do
      expect(NiceHash.transtring({ foo: :bar })).to eq "foo.bar"
    end
  end

  describe "get_all_keys" do
    it "gets all keys from hash with nested arrays of hashes" do
      h = { a: 1, b: [{ c: 2 }, { d: 3 }] }
      expect(NiceHash.get_all_keys(h)).to match_array [:a, :b, :c, :d]
    end
  end

  describe "String#json" do
    it "returns empty hash for invalid JSON" do
      expect("not json at all".json).to eq({})
    end

    it "returns parsed structure when no keys given" do
      expect('{"a":1,"b":2}'.json).to eq({ a: 1, b: 2 })
    end

    it "returns empty hash for one key that does not exist" do
      expect('{"a":1}'.json(:missing)).to eq({})
    end
  end

  describe "Array#json" do
    it "returns empty hash for empty array" do
      expect([].json(:id)).to eq({})
    end
  end

  describe "nice_filter" do
    it "returns only present keys when some keys are missing" do
      my_hash = { a: 1, b: { c: 2 } }
      result = NiceHash.nice_filter(my_hash, [:a, :'b.c', :'b.missing.x'])
      expect(result).to eq({ a: 1, b: { c: 2 } })
    end

    it "handles array of hashes" do
      arr = [{ name: "Peter", age: 33 }, { name: "Jane", age: 44 }]
      result = NiceHash.nice_filter(arr, [:name])
      expect(result).to eq([{ name: "Peter" }, { name: "Jane" }])
    end
  end

  describe "Hash#respond_to? with method_missing keys" do
    it "returns true for existing key as method" do
      h = { address: "Madrid" }
      expect(h.respond_to?(:address)).to be true
    end

    it "returns true for existing key with underscore prefix" do
      h = { display: true }
      expect(h.respond_to?(:_display)).to be true
    end

    it "returns false for non-existing key" do
      h = { address: "Madrid" }
      expect(h.respond_to?(:nonexistent)).to be false
    end
  end

  describe "Array#respond_to? with method_missing keys" do
    it "returns true when key exists in any hash element" do
      arr = [{ name: "Peter" }, { name: "Jane" }]
      expect(arr.respond_to?(:name)).to be true
    end

    it "returns false when key exists in no hash element" do
      arr = [{ name: "Peter" }]
      expect(arr.respond_to?(:missing_key)).to be false
    end
  end
end
