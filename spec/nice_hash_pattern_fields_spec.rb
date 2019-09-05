RSpec.describe NiceHash, "#pattern_fields" do
  it "returns the pattern fields" do
    res = NiceHash.pattern_fields(@hash)
    pf = [[:address, :correct],
          [:products, 0, :name],
          [:products, 0, :price, :correct],
          [:products, 1, :name],
          [:products, 1, :price, :correct]]
    expect(res).to eq (pf)
  end
  it "returns the pattern fields when using class Hash" do
    res = @hash.pattern_fields
    pf = [[:address, :correct],
          [:products, 0, :name],
          [:products, 0, :price, :correct],
          [:products, 1, :name],
          [:products, 1, :price, :correct]]
    expect(res).to eq (pf)
  end
  it "returns the pattern fields with selected keys" do
    res = NiceHash.pattern_fields(@hash, :correct)
    pf = [
      [:address],
      [:products, 0, :name],
      [:products, 0, :price],
      [:products, 1, :name],
      [:products, 1, :price],
    ]
    expect(res).to eq (pf)
  end
  #   my_hash.patterns(:correct)
  it "returns the pattern fields with selected keys using Hash class" do
    res = @hash.pattern_fields(:correct)
    pf = [
      [:address],
      [:products, 0, :name],
      [:products, 0, :price],
      [:products, 1, :name],
      [:products, 1, :price],
    ]
    expect(res).to eq (pf)
  end
  it "accepts patterns as alias" do
    res = @hash.patterns(:correct)
    pf = [
      [:address],
      [:products, 0, :name],
      [:products, 0, :price],
      [:products, 1, :name],
      [:products, 1, :price],
    ]
    expect(res).to eq (pf)
  end
end
