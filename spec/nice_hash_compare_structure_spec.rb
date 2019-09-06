require "nice_hash"

RSpec.describe NiceHash, "#compare_structure" do
  before(:each) do
    @my_structure = [
      { name: "xxx",
       zip: "yyyy",
       customer: true,
       product_ids: [1] },
    ]
    @my_replica = [{ name: "Peter Ben", zip: "1121A", customer: false, product_ids: [] },
                   { name: "John Woop", zip: "74014", customer: true, product_ids: [10, 120, 301] }]
  end

  it "returns true if structure as replica" do
    expect(NiceHash.compare_structure(@my_structure, @my_replica)).to eq true
  end
end
