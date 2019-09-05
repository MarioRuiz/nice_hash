
RSpec.describe NiceHash, "#set_values" do
  it "returns the hash with values set" do
    new_hash = NiceHash.set_values(@hashw, { city: "London", price: "1000" })
    expect(new_hash).to eq ({ :name => "Peter", :address => "\#$$$$$", :city => "London", :products => [{ :name => :"10:Ln", :price => "1000" }, { :name => :"10:Ln", :price => "1000" }] })
  end
  it "returns the hash with values set when using hash class" do
    new_hash = @hashw.set_values({ city: "London", price: "1000" })
    expect(new_hash).to eq ({ :name => "Peter", :address => "\#$$$$$", :city => "London", :products => [{ :name => :"10:Ln", :price => "1000" }, { :name => :"10:Ln", :price => "1000" }] })
  end
  it "returns the hash with values set when using nested keys" do
    new_hash = @hashw.set_values({ city: "London", 'products.price': "1000" })
    expect(new_hash).to eq ({ :name => "Peter", :address => "\#$$$$$", :city => "London", :products => [{ :name => :"10:Ln", :price => "1000" }, { :name => :"10:Ln", :price => "1000" }] })
  end
end
