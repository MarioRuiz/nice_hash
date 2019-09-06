require "nice_hash"

RSpec.describe NiceHash, "#generate" do
  it "returns the hash with generated values" do
    new_hash = NiceHash.generate(@hash)
    expect(@hash.address.correct.validate(new_hash.address.correct)).to be_empty
    expect(@hash.city.correct.to_s.split("|").include?(new_hash.city.correct)).to eq true
    expect(@hash.products[0].price.correct.validate(new_hash.products[0].price.correct)).to be_empty
    expect(@hash.products[1].price.correct.validate(new_hash.products[1].price.correct)).to be_empty
  end

  it "returns the hash with generated values with select key" do
    new_hash = NiceHash.generate(@hash, :correct)
    expect(@hash.address.correct.validate(new_hash.address)).to be_empty
    expect(@hash.city.correct.to_s.split("|").include?(new_hash.city)).to eq true
    expect(@hash.products[0].price.correct.validate(new_hash.products[0].price)).to be_empty
    expect(@hash.products[1].price.correct.validate(new_hash.products[1].price)).to be_empty
  end

  it "returns the hash with generated values using select key before" do
    new_hash = @hash.select_key(:correct).generate
    expect(@hash.address.correct.validate(new_hash.address)).to be_empty
    expect(@hash.city.correct.to_s.split("|").include?(new_hash.city)).to eq true
    expect(@hash.products[0].price.correct.validate(new_hash.products[0].price)).to be_empty
    expect(@hash.products[1].price.correct.validate(new_hash.products[1].price)).to be_empty
  end

  it "returns the hash with generated wrong min_length values - nested " do
    new_hash = NiceHash.generate(@hash, :correct, expected_errors: [:min_length])
    expect(@hash.address.correct.validate(new_hash.address, errors: [:min_length])).to eq true
    expect(!@hash.city.correct.to_s.split("|").include?(new_hash.city)).to eq true
    expect(@hash.products[0].price.correct.validate(new_hash.products[0].price, errors: [:min_length])).to eq true
    expect(@hash.products[1].price.correct.validate(new_hash.products[1].price, errors: [:min_length])).to eq true
  end

  it "returns the hash with generated wrong min_length values " do
    hash = NiceHash.generate(@hashopt, expected_errors: [:min_length])
    expect(hash.created.size < 24).to eq true
    expect(hash.name.size < 10).to eq true
    expect(hash.pwd1.size < 5).to eq true
    expect(hash.age < 18).to eq true
    expect(hash.euros < -3000).to eq true
    expect(hash.reports.size < 5).to eq true
    expect(hash.username.size < 10).to eq true
  end

  it "returns the hash with generated wrong max_length values" do
    hash = NiceHash.generate(@hashopt, expected_errors: [:max_length])
    expect(hash.created.size > 24).to eq true
    expect(hash.name.size > 20).to eq true
    expect(hash.pwd1.size > 10).to eq true
    expect(hash.age > 120).to eq true
    expect(hash.euros > 3000).to eq true
    expect(hash.reports.size > 7).to eq true
    expect(hash.username.size > 20).to eq true
  end

  it "returns the hash with generated wrong length values" do
    hash = NiceHash.generate(@hashopt, expected_errors: [:length])
    expect(hash.created.size != 24).to eq true
    expect(hash.name.size).not_to be_between(10, 20)
    expect(hash.pwd1.size).not_to be_between(5, 10)
    expect(hash.age).not_to be_between(18, 120)
    expect(hash.euros).not_to be_between(-3000, 3000)
    expect(hash.reports.size).not_to eq 5
    expect(hash.reports.size).not_to eq 7
    expect(hash.username.size).not_to be_between(10, 20)
  end

  it "returns the hash with generated wrong value" do
    hash = NiceHash.generate(@hashopt, expected_errors: [:value])
    expect(hash.customer.to_s != "true").to eq true
    expect(hash.customer.to_s != "false").to eq true
    expect(hash.created).not_to match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/)
    expect(hash.name).not_to match(/^[a-zA-Z\s]{10,20}$/)
    expect(hash.pwd1).not_to match(/^([a-zA-Z]?\d){5,10}$/)
    expect(hash.age).not_to match(/^\d+$/)
    expect(hash.euros).not_to match(/^\d+$/)
    expect(hash.reports.to_s != "Weekely").to eq true
    expect(hash.reports.to_s != "Daily").to eq true
    expect(hash.username).not_to match(/^[a-z]{10,20}$/)
  end

  it "returns the hash with generated wrong value and string_set_not_allowed" do
    hash = NiceHash.generate(@hashopt, expected_errors: [:string_set_not_allowed])
    #todo: when Boolean is returning a valid boolean, verify if that's as expected
    #expect(hash.customer.to_s).not_to eq 'true'
    #expect(hash.customer.to_s).not_to eq 'false'
    #todo: when DateTime is returning a valid date, verify if that's as expected
    #expect(hash.created).not_to match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/)
    expect(hash.name).not_to match(/^[a-zA-Z\s]{10,20}$/)
    expect(hash.pwd1).not_to match(/^([a-zA-Z]?\d){5,10}$/)
    expect(hash.age).not_to match(/^\d+$/)
    expect(hash.euros).not_to match(/^\d+$/)
    expect(hash.reports.to_s != "Weekely").to eq true
    expect(hash.reports.to_s != "Daily").to eq true
    expect(hash.username).not_to match(/^[a-z]{10,20}$/)
  end

  it "generates random values for all possibilities" do
    res = @hashopt.gen
    expect([true, false]).to include(res.customer)
    expect(res.created).to match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/)
    expect(res.name).to match(/^[a-zA-Z\s]{10,20}$/)
    expect(res.pwd1).to eq res.pwd2
    expect(res.pwd1).to eq res.pwd3
    expect(res.age).to be_between(18, 120)
    expect(res.euros).to be_between(-3000.0, 3000.0)
    expect(["Weekely", "Daily"]).to include(res.reports)
    expect(res.username).to match(/^[a-z]{10,20}$/)
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
    my_hash.send_email = "false"
    expect(my_hash.gen.email).to eq ""
  end
end
