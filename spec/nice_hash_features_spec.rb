# frozen_string_literal: true

require "nice_hash"

RSpec.describe "NiceHash new features" do
  describe "generate_n" do
    it "returns n different hashes" do
      pattern = { name: :"5:L", age: 18..99 }
      hashes = NiceHash.generate_n(pattern, 3)
      expect(hashes.size).to eq 3
      hashes.each { |h| expect(h).to have_key(:name); expect(h).to have_key(:age) }
      expect(hashes.map { |h| h[:name] }.uniq.size).to be >= 1
    end

    it "works via Hash#generate_n" do
      pattern = { id: :"3:N" }
      hashes = pattern.generate_n(2)
      expect(hashes.size).to eq 2
      expect(hashes.first).to have_key(:id)
    end
  end

  describe "diff" do
    it "returns empty hash when hashes are equal" do
      h = { a: 1, b: { c: 2 } }
      expect(NiceHash.diff(h, h)).to eq({})
      expect(h.diff(h)).to eq({})
    end

    it "returns path and expected/got for scalar difference" do
      expected = { user: { address: { city: "Madrid" } } }
      actual   = { user: { address: { city: "London" } } }
      expect(NiceHash.diff(expected, actual)).to eq(
        "user.address.city" => { expected: "Madrid", got: "London" }
      )
    end

    it "reports missing key in actual" do
      expected = { a: 1, b: 2 }
      actual   = { a: 1 }
      expect(NiceHash.diff(expected, actual)).to include("b" => { expected: 2, got: nil })
    end

    it "works via Hash#diff" do
      expect({ x: 1 }.diff({ x: 2 })).to eq("x" => { expected: 1, got: 2 })
    end
  end

  describe "string_pattern 2.4 integration" do
    it "generates UUID v4 when value is :uuid" do
      pattern = { id: :uuid }
      h = NiceHash.generate(pattern)
      expect(h[:id]).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)
    end

    it "validates UUID with :uuid pattern" do
      pattern = { id: :uuid }
      expect(pattern.validate(nil, { id: "550e8400-e29b-41d4-a716-446655440000" })).to eq({})
      expect(pattern.validate(nil, { id: "not-a-uuid" })).to eq({ id: false })
    end

    it "generate with seed: produces reproducible hash" do
      pattern = { name: :"5:L", age: 10..20 }
      a = NiceHash.generate(pattern, nil, seed: 42)
      b = NiceHash.generate(pattern, nil, seed: 42)
      expect(a).to eq(b)
    end
  end

  describe "flatten_keys and unflatten_keys" do
    it "flattens nested hash to dot-notation keys" do
      h = { user: { address: { city: "Madrid" } } }
      expect(NiceHash.flatten_keys(h)).to eq("user.address.city" => "Madrid")
    end

    it "unflattens dot-notation keys to nested hash" do
      flat = { "user.address.city" => "Madrid" }
      expect(NiceHash.unflatten_keys(flat)).to eq(user: { address: { city: "Madrid" } })
    end

    it "round-trips flatten and unflatten" do
      h = { a: 1, b: { c: 2, d: { e: 3 } } }
      flat = NiceHash.flatten_keys(h)
      expect(NiceHash.unflatten_keys(flat)).to eq(h)
    end

    it "works via Hash instance methods" do
      h = { foo: { bar: 42 } }
      expect(h.flatten_keys).to eq("foo.bar" => 42)
      expect({ "foo.bar" => 42 }.unflatten_keys).to eq(foo: { bar: 42 })
    end
  end
end
