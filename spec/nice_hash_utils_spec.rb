require "nice_hash"

RSpec.describe NiceHash do
  it "Translate a hash of hashes into a string separted by ." do
    my_hash = { uno: { dos: :tres } }
    expect(NiceHash.transtring(my_hash)).to eq "uno.dos.tres"
  end

  it "gets all keys from a hash" do
    my_hash = { uno: { dos: { tres: 3 } } }
    expect(NiceHash.get_all_keys(my_hash)).to eq ([:uno, :dos, :tres])
  end

  it "deletes nested keys" do
    my_hash = { user: {
                        address: {
                          city: "Madrid",
                          country: "Spain",
                        },
                        name: "Peter",
                        age: 33,
                      },
               customer: true }
    expect(NiceHash.delete_nested(my_hash, "user.address.city")).to eq ({ :user => { :address => { :country => "Spain" }, :name => "Peter", :age => 33 }, :customer => true })
  end

  it "sets the supplied value on the supplied nested key" do
    my_hash = { user: {
                        address: {
                          city: "Madrid",
                          country: "Spain",
                        },
                        name: "Peter",
                        age: 33,
                      },
               customer: true }
    expect(NiceHash.set_nested(my_hash, "user.address.city", "Barcelona")).to eq ({ :user => { :address => { :city => "Barcelona", :country => "Spain" }, :name => "Peter", :age => 33 }, :customer => true })
  end

  it "filters the hash supplied and returns only the specified keys" do
    my_hash = { user: {
                        address: {
                          city: "Madrid",
                          country: "Spain",
                        },
                        name: "Peter",
                        age: 33,
                        customers: [{ name: "Peter", currency: "Euro" }, { name: "John", currency: "Euro" }],
                      },
               customer: true }
    expected_result = { :user => { :address => { :city => "Madrid" }, :customers => [{ :name => "Peter" }, { :name => "John" }] }, :customer => true }
    expect(NiceHash.nice_filter(my_hash, [:'user.address.city', :'customer', :'user.customers.name'])).to eq (expected_result)
  end
end
