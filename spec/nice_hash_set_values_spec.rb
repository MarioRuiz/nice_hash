require "nice_hash"

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
  it "sets nested keys" do
    new_hash = NiceHash.set_values(@hashw, { 'products.name': :'Doom' })
    expect(new_hash).to eq ({ :name => "Peter", :address => "\#$$$$$", :city => "Germany", :products => [{ :name => :"Doom", :price => "-20" }, { :name => :"Doom", :price => "-30" }] })
  end

  it "sets everything as described on readme" do
    my_hash = {
      path: "/api/users",
      data: {
        name: "morpheus",
        job: "leader",
        lab: {
          doom: "one",
          beep: true,
          name: "mario",
          products: [
            {
              name: "game",
              price: 30,
            },
            {
              name: "chair",
              price: 130,
            },
          ],
        },
      },
    }

    hash2 = NiceHash.set_values(my_hash, { price: 75, beep: false })
    expect(hash2.data.lab.beep).to eq false
    expect(hash2.data.lab.products[0].price).to eq 75
    expect(hash2.data.lab.products[1].price).to eq 75
    hash2 = my_hash.set_values({ price: 75, beep: false })
    expect(hash2.data.lab.beep).to eq false
    expect(hash2.data.lab.products[0].price).to eq 75
    expect(hash2.data.lab.products[1].price).to eq 75
    hash2 = my_hash.set_values({ 'data.lab.products.price': 75, 'data.lab.beep': false })
    expect(hash2.data.lab.beep).to eq false
    expect(hash2.data.lab.products[0].price).to eq 75
    expect(hash2.data.lab.products[1].price).to eq 75
  end
  it "returns the object if no hash or empty array or hash" do
    expect(NiceHash.set_values({}, { price: 75 })).to eq ({})
    expect(NiceHash.set_values([], { price: 75 })).to eq ([])
    expect(NiceHash.set_values("uno", { price: 75 })).to eq ("uno")
  end
end
