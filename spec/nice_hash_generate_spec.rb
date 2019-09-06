require "nice_hash"

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

  it "returns the hash with generated values using select key before" do
    new_hash = @hash.select_key(:correct).generate
    expect(@hash.address.correct.validate(new_hash.address))
    expect(@hash.city.correct.to_s.split("|").include?(new_hash.city))
    expect(@hash.products[0].price.correct.validate(new_hash.products[0].price))
    expect(@hash.products[1].price.correct.validate(new_hash.products[1].price))
  end

  it "returns the hash with generated wrong min_length values " do
    new_hash = NiceHash.generate(@hash, :correct, expected_errors: [:min_length])
    expect(@hash.address.correct.validate(new_hash.address, errors: [:min_length]))
    expect(!@hash.city.correct.to_s.split("|").include?(new_hash.city))
    expect(@hash.products[0].price.correct.validate(new_hash.products[0].price, errors: [:min_length]))
    expect(@hash.products[1].price.correct.validate(new_hash.products[1].price, errors: [:min_length]))
  end

  it "generates random values for all possibilities" do
    res = @hashopt.gen
    expect([true, false]).to include(res.customer)
    expect(res.created).to match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/)
    expect(res.name).to match(/[a-zA-Z\s]{10,20}/)
    expect(res.pwd1).to eq res.pwd2
    expect(res.pwd1).to eq res.pwd3
    expect(res.age).to be_between(18, 120)
    expect(res.euros).to be_between(-3000.0, 3000.0)
    expect(["Weekely", "Daily"]).to include(res.reports)
    expect(res.username).to match(/[a-z]{10,20}/)
  end

  it "adds values on run time using lambda" do
    my_hash = {
      loginname: :"10:Ln",
      datetime: lambda {
        Time.now.stamp
      },
      other: Time.now.stamp,
    }
    res1 = my_hash.gen
    sleep 0.001
    res2 = my_hash.gen
    expect(res1.datetime).not_to eq res2.datetime
  end
  it "access other values of the hash on run time using lambda" do
    my_hash = {
      loginname: :"10:Ln",
      send_email: "true",
      email: lambda {
        if NiceHash.values._send_email == "true"
          :"30-50:@".gen
        else
          ""
        end
      },
    }
    expect(my_hash.gen.email).not_to eq ""
  end
end
