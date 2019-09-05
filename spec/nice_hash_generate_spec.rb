require 'nice_hash'

RSpec.describe NiceHash, "#generate" do
  it "returns the hash with generated values" do
    new_hash = NiceHash.generate(@hash)
    expect(@hash.address.correct.validate(new_hash.address.correct))
    expect(@hash.city.correct.to_s.split("|").include?(new_hash.city.correct))
    expect(@hash.products[0].price.correct.validate(new_hash.products[0].price.correct))
    expect(@hash.products[1].price.correct.validate(new_hash.products[1].price.correct))
  end

  it "returns the hash with generated values with select key" do
    new_hash = NiceHash.generate(@hash, :correct)
    expect(@hash.address.correct.validate(new_hash.address))
    expect(@hash.city.correct.to_s.split("|").include?(new_hash.city))
    expect(@hash.products[0].price.correct.validate(new_hash.products[0].price))
    expect(@hash.products[1].price.correct.validate(new_hash.products[1].price))
  end

end
