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

  it "is possible to access keys all the different manners" do
    my_hash = @my_hash.deep_copy
    expect(my_hash[:address]).to eq "21 Doom Av"
    expect(my_hash.address).to eq "21 Doom Av"
    my_hash.address = "99 Danish Street" #assignment
    expect(my_hash.address).to eq "99 Danish Street"
    expect(my_hash.mobilePhone.correct).to eq (["(", :"3:N", ")", :"6-8:N"])
    expect(my_hash.draws[1].owner.correct).to eq :'20:L'

    expect(my_hash._address).to eq "99 Danish Street"
    my_hash._address = "299 Danish Street" #assignment
    expect(my_hash.address).to eq "299 Danish Street"
    expect(my_hash._mobilePhone._correct).to eq (["(", :"3:N", ")", :"6-8:N"])
    expect(my_hash._draws[1]._owner.correct).to eq :'20:L' #mixed
  end

  it "is possible to use array of hashes" do
    my_array = [{ name: "Peter", city: "Madrid" }, { name: "Lola", city: "NYC" }]
    expect(my_array.city).to eq (["Madrid", "NYC"])
    expect(my_array._name).to eq (["Peter", "Lola"])
  end

  it "buries the value" do
    default_values = @my_hash.generate :default
    default_values.bury([:draws, 0, :drawName], "FirstDraw")
    expect(default_values.draws[0].drawName).to eq "FirstDraw"
  end

  it "returns time stamp" do
    expect(Time.now.stamp).to match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/)
  end

  it "returns random dates" do
    # random date from today to 60 days after
    date = Date.today.random(60)
    expect(date <= Date.today + 60)
    expect(date >= Date.today)

    # random date from 01-09-2005 to 100 days later
    date = Date.strptime("01-09-2005", "%d-%m-%Y").random(100)
    expect(date <= Date.new(2005, 9, 1) + 100)
    expect(date >= Date.new(2005, 9, 1))

    # random date from 2003/10/31 to today
    date = Date.new(2003, 10, 31).random(Date.today)
    expect(date <= Date.today)
    expect(date >= Date.new(2003, 10, 31))
  end

  it "deep copies of a hash" do
    my_hash = { one: 1, two: 2, three: { car: "seat" } }

    my_new_hash = my_hash.deep_copy # using deep_copy method
    my_new_hash[:three][:car] = "changed"
    my_new_hash[:two] = "changed"
    # my_hash doesn't change
    expect(my_hash).to eq ({ :one => 1, :two => 2, :three => { :car => "seat" } })

    my_new_hash = my_hash.clone # using clone or dup or direct assignment
    my_new_hash[:three][:car] = "changed"
    my_new_hash[:two] = "changed"
    # my_hash changed!
    expect(my_hash).to eq ({ :one => 1, :two => 2, :three => { :car => "changed" } })
  end

  it "accepts Boolean class" do
    value = true
    text = "true"

    expect(value.is_a?(Boolean)).to eq true
    expect(text.is_a?(Boolean)).to eq false
  end
end
