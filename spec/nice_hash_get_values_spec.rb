require "nice_hash"

RSpec.describe NiceHash, "#get_values" do
  before(:each) do
    @example = { "id" => 344,
                "customer" => {
      "name" => "Peter Smith",
      "phone" => 334334333,
    },
                "tickets" => [
      { "idt" => 345, "name" => "myFavor1" },
      { "idt" => 3123 },
      { "idt" => 3145, "name" => "Special ticket" },
    ] }
  end

  it "get_values with keys as strings" do
    res = @example.get_values("id", "name")
    expect(res).to eq ({ "id" => 344, "name" => ["Peter Smith", ["myFavor1", "Special ticket"]] })
  end

  it "get_values with keys as array" do
    res = @example.get_values(["id", "name"])
    expect(res).to eq ({ "id" => 344, "name" => ["Peter Smith", ["myFavor1", "Special ticket"]] })
  end

  it "get_values with keys as single string" do
    res = @example.get_values("idt")
    expect(res).to eq ({ "idt" => [345, 3123, 3145] })
  end

  it "get_values with keys as nested symbols" do
    res = @example.get_values(:"tickets.idt")
    expect(res).to eq ({ :"tickets.idt" => [345, 3123, 3145] })
  end

  it "is possible to use json method" do
    my_json_string = "{\"id\":344,\"customer\":{\"name\":\"Peter Smith\",\"phone\":334334333},\"tickets\":[{\"idt\":345,\"name\":\"myFavor1\"},{\"idt\":3123},{\"idt\":3145,\"name\":\"Special ticket\"}]}"
    expect(my_json_string.json(:idt)).to eq ([345, 3123, 3145])
    expect(my_json_string.json(:idt, :name)).to eq ({ :name => ["Peter Smith", ["myFavor1", "Special ticket"]], :idt => [345, 3123, 3145] })
  end

  it "returns expected values for all cases as described on readme" do
    new_hash = @my_hash.generate
    expect(new_hash.get_values(:address)).to eq ({ :address => "21 Doom Av" })
    expect(new_hash.get_values(:address, :zip)).to eq ({ :zip => new_hash[:zip], :address => "21 Doom Av" })
    expect(new_hash.get_values(:drawId)).to eq ({ :drawId => [new_hash[:draws][0][:drawId], new_hash[:draws][1][:drawId]] })
    #using nested keys
    expect(new_hash.get_values(:'draws.drawId')).to eq ({ :'draws.drawId' => [new_hash[:draws][0][:drawId], new_hash[:draws][1][:drawId]] })
  end
end
