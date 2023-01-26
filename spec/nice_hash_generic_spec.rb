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

  it "sets the supplied value on the supplied key when no nested but using set_nested" do
    my_hash = { user: {
                        address: {
                          city: "Madrid",
                          country: "Spain",
                        },
                        name: "Peter",
                        age: 33,
                      },
                customer: true }
    expect(NiceHash.set_nested(my_hash, "customer", false)).to eq ({ :user => { :address => { :city => "Madrid", :country => "Spain" }, :name => "Peter", :age => 33 }, :customer => false })
  end

  it "sets the supplied value on the supplied nested key only if exists" do
    my_hash = { user: {
                        address: {
                          city: "Madrid",
                          country: "Spain",
                        },
                        name: "Peter",
                        age: 33,
                      },
                customer: true }
    expect(NiceHash.set_nested(my_hash, "user.address.city", "Barcelona", true)).to eq ({ :user => { :address => { :city => "Barcelona", :country => "Spain" }, :name => "Peter", :age => 33 }, :customer => true })
    expect(NiceHash.set_nested(my_hash, "user.address.cityx", "Reykjavik", true)).to eq ({ :user => { :address => { :city => "Barcelona", :country => "Spain" }, :name => "Peter", :age => 33 }, :customer => true })
    expect(NiceHash.set_nested(my_hash, "user.age", 55, true)).to eq ({ :user => { :address => { :city => "Barcelona", :country => "Spain" }, :name => "Peter", :age => 55 }, :customer => true })
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

  it "filters the hash supplied and returns only the specified keys using Hash class" do
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
    expect(my_hash.nice_filter([:'user.address.city', :'customer', :'user.customers.name'])).to eq (expected_result)
  end

  it "filters the array supplied and returns only the specified keys" do
    my_hash = [{ user: {
      address: {
        city: "Madrid",
        country: "Spain",
      },
      name: "Peter",
      age: 33,
      customers: [{ name: "Peter", currency: "Euro" }, { name: "John", currency: "Euro" }],
    },
                 customer: true }]
    expected_result = [{ :user => { :address => { :city => "Madrid" }, :customers => [{ :name => "Peter" }, { :name => "John" }] }, :customer => true }]
    expect(my_hash.nice_filter([:'user.address.city', :'customer', :'user.customers.name'])).to eq (expected_result)
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

  it "buries the value in hashes" do
    default_values = @my_hash.generate :default
    default_values.bury([:draws, 0, :drawName], "FirstDraw")
    expect(default_values.draws[0].drawName).to eq "FirstDraw"
  end

  it "buries the value in arrays" do
    default_values = [@my_hash.generate(:default)]
    default_values.bury([0, :draws, 0, :drawName], "FirstDraw")
    expect(default_values[0].draws[0].drawName).to eq "FirstDraw"
  end

  it "returns time stamp" do
    expect(Time.now.stamp).to match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/)
  end

  it "returns random dates" do
    # random date from today to 60 days after
    date = Date.today.random(60)
    expect(date <= Date.today + 60).to eq true
    expect(date >= Date.today).to eq true

    # random date from 01-09-2005 to 100 days later
    date = Date.strptime("01-09-2005", "%d-%m-%Y").random(100)
    expect(date <= Date.new(2005, 9, 1) + 100).to eq true
    expect(date >= Date.new(2005, 9, 1)).to eq true

    # random date from 2003/10/31 to today
    date = Date.new(2003, 10, 31).random(Date.today)
    expect(date <= Date.today).to eq true
    expect(date >= Date.new(2003, 10, 31)).to eq true
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
  it "compares integer with string" do
    expect("10" == 10).to eq true
  end

  it "deep symbolize keys on hashes" do
    my_hash = { "uno" => { "dos" => { "tres" => 3 } } }
    expect(my_hash.deep_symbolize_keys).to eq ({ :'uno' => { :'dos' => { :'tres' => 3 } } })
  end
  it "deep symbolize keys on arrays" do
    my_hash = [{ "uno" => { "dos" => { "tres" => 3 } } }]
    expect(my_hash.deep_symbolize_keys).to eq ([{ :'uno' => { :'dos' => { :'tres' => 3 } } }])
  end
  it 'access the string keys as methods' do
    hash = {'uno'=> 1, dos: 2, 'tres': 3}
    expect(hash._tres).to eq 3
    expect(hash.tres).to eq 3
    expect(hash.dos).to eq 2
    expect(hash.uno).to eq 1
    hash.uno = 11
    expect(hash.uno).to eq 11
    hash._uno = 111
    expect(hash.uno).to eq 111
    hash.dos = 22
    expect(hash.dos).to eq 22
    hash._dos = 222
    expect(hash.dos).to eq 222
    expect(hash).to eq({"uno"=>111, :dos=>222, :tres=>3})
  end

  it 'returns true if object in? array' do
    expect('uno'.in?(['uno','dos'])).to be true
    expect(:uno.in? [:uno, :dos]).to be true
    expect(5.in? [1,2,3,4,5]).to be true
  end

  it 'returns false if object not in? array' do
    expect('unox'.in?(['uno','dos'])).to be false
    expect(:unox.in? [:uno, :dos]).to be false
    expect(6.in? [1,2,3,4,5]).to be false
  end

  it "deep merge two hashes" do
    my_hash = { one: 1, two: 2, three: { car: "seat", model: 'none' }, four: [{five: 5}] }
    other_hash = {one: 11, three: { car: "changed" }, four: [{five: 55}] }

    my_new_hash = my_hash.nice_merge(other_hash)
    expect(my_new_hash).to eq ({ :one => 11, :two => 2, :three => { :car => "changed", :model => 'none' }, :four => [{:five => 55}] })
  end


end
