# frozen_string_literal: true

require "nice_hash"

RSpec.describe "NiceHash additional coverage" do
  describe "change_one_by_one" do
    it "handles same_values (multiple keys sharing one pattern)" do
      pattern = { [:pwd1, :pwd2] => :"3-5:Ln" }
      wrong = pattern.generate(errors: :min_length)
      array = NiceHash.change_one_by_one(pattern, wrong)
      expect(array).to be_an(Array)
      expect(array.size).to be >= 1
      array.each do |h|
        expect(h).to have_key(:pwd1)
        expect(h).to have_key(:pwd2)
      end
    end
  end

  describe "diff" do
    it "reports differences in arrays by index" do
      expected = { items: [{ name: "a" }, { name: "b" }] }
      actual   = { items: [{ name: "a" }, { name: "x" }] }
      d = NiceHash.diff(expected, actual)
      expect(d).to have_key("items[1].name")
      expect(d["items[1].name"][:expected]).to eq "b"
      expect(d["items[1].name"][:got]).to eq "x"
    end

    it "reports when actual has extra key" do
      expected = { a: 1 }
      actual   = { a: 1, b: 2 }
      d = NiceHash.diff(expected, actual)
      expect(d).to have_key("b")
      expect(d["b"][:expected]).to be_nil
      expect(d["b"][:got]).to eq 2
    end

    it "handles nil values" do
      expect(NiceHash.diff({ a: nil }, { a: 1 })).to eq("a" => { expected: nil, got: 1 })
    end
  end

  describe "flatten_keys" do
    it "keeps array values as leaves" do
      h = { user: { tags: %w[a b c] } }
      flat = NiceHash.flatten_keys(h)
      expect(flat).to eq("user.tags" => %w[a b c])
    end

    it "returns empty hash for empty hash" do
      expect(NiceHash.flatten_keys({})).to eq({})
    end
  end

  describe "unflatten_keys" do
    it "returns empty hash for empty hash" do
      expect(NiceHash.unflatten_keys({})).to eq({})
    end

    it "handles numeric key segments" do
      flat = { "a.0.b" => 1 }
      expect(NiceHash.unflatten_keys(flat)).to eq({ a: { 0 => { b: 1 } } })
    end
  end

  describe "validate" do
    it "returns error hash for invalid pattern_hash type" do
      result = NiceHash.validate("not a hash", { a: 1 })
      expect(result).to eq({ error: :error })
    end
  end

  describe "compare_structure with patterns" do
    it "validates values against patterns when patterns given" do
      structure = [{ name: "x", zip: "12345" }]
      replica_ok = [{ name: "Peter", zip: "90210" }]
      replica_bad_zip = [{ name: "Jane", zip: "bad" }]
      patterns = { zip: /\A\d{5}\z/ }
      expect(NiceHash.compare_structure(structure, replica_ok, false, patterns)).to be true
      expect(NiceHash.compare_structure(structure, replica_bad_zip, false, patterns)).to be false
    end
  end

  describe "set_nested" do
    it "does not set when only_if_exist is true and full path does not exist" do
      hash = { a: { b: "original" } }
      result = NiceHash.set_nested(hash, "a.c.x", "new", true)
      expect(result).to eq(hash)
      expect(hash.dig(:a, :c)).to be_nil
    end
  end

  describe "delete_nested" do
    it "returns hash unchanged when nested path does not exist" do
      hash = { a: { b: "keep" } }
      result = NiceHash.delete_nested(hash, "a.x.y")
      expect(result).to eq(hash)
      expect(hash[:a][:b]).to eq "keep"
    end
  end

  describe "generate" do
    it "returns empty hash for empty pattern hash" do
      expect(NiceHash.generate({})).to eq({})
    end
  end

  describe "Hash#has_rkey?" do
    it "returns true when key matches string (substring)" do
      h = { address: 1, other: 2 }
      expect(h.has_rkey?("addr")).to be true
    end

    it "returns true when key matches symbol" do
      h = { my_key: 1 }
      expect(h.has_rkey?(:my_key)).to be true
    end

    it "returns true when key matches regexp" do
      h = { user_name: 1, user_age: 2 }
      expect(h.has_rkey?(/^user_/)).to be true
    end

    it "returns false when no key matches" do
      h = { foo: 1 }
      expect(h.has_rkey?("bar")).to be false
    end
  end
end
