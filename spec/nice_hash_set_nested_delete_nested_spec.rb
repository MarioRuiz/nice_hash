# frozen_string_literal: true

require "nice_hash"

RSpec.describe NiceHash, "set_nested and delete_nested (no eval)" do
  it "set_nested does not interpret malicious key or value as code" do
    hash = { a: { b: "safe" } }
    # Keys/values that would be dangerous if passed to eval
    NiceHash.set_nested(hash, "a.b", "'; system('echo pwned'); '")
    expect(hash[:a][:b]).to eq "'; system('echo pwned'); '"
  end

  it "delete_nested does not interpret malicious path as code" do
    hash = { a: { b: "v" } }
    NiceHash.delete_nested(hash, "a.b'); puts 'pwned'; #")
    expect(hash).to eq({ a: { b: "v" } })
  end
end
