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
end
