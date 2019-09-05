RSpec.describe NiceHash, "#select_key" do
  it "returns the hash with selected keys" do
    new_hash = NiceHash.select_key(@hash, :wrong)
    expect(new_hash).to eq ({ :name => "Peter", :address => "\#$$$$$", :city => "Germany", :products => [{ :name => :"10:Ln", :price => "-20" }, { :name => :"10:Ln", :price => "-30" }] })
  end
  it "returns the hash with selected keys when using hash class" do
    new_hash = @hash.select_key(:wrong)
    expect(new_hash).to eq ({ :name => "Peter", :address => "\#$$$$$", :city => "Germany", :products => [{ :name => :"10:Ln", :price => "-20" }, { :name => :"10:Ln", :price => "-30" }] })
  end
end
