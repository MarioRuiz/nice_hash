require "nice_hash"

RSpec.describe NiceHash, "#select_fields" do
  it "returns the select fields" do
    res = NiceHash.select_fields(@hash)
    pf = [[:city, :correct]]
    expect(res).to eq (pf)
  end
  it "returns the select fields when using class Hash" do
    res = @hash.select_fields
    pf = [[:city, :correct]]
    expect(res).to eq (pf)
  end
  it "returns the select fields with selected keys" do
    res = NiceHash.select_fields(@hash, :correct)
    pf = [[:city]]
    expect(res).to eq (pf)
  end
  #   my_hash.patterns(:correct)
  it "returns the pattern fields with selected keys using Hash class" do
    res = @hash.select_fields(:correct)
    pf = [[:city]]
    expect(res).to eq (pf)
  end
end
