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


  it "returns the hash with generated wrong max_length values " do
    hash = NiceHash.generate(@hashopt, expected_errors: [:max_length])
    expect(hash.created.size>24)
    expect(hash.name.size>20)
    expect(hash.pwd1.size>10)
    expect(hash.age>120)
    expect(hash.euros>3000)
    expect(hash.reports.size>7)
    expect(hash.username.size>20)
  end

  it "returns the hash with generated wrong value" do
    hash = NiceHash.generate(@hashopt, expected_errors: [:value])
    expect(hash.customer.to_s!='true')
    expect(hash.customer.to_s!='false')
    expect(hash.created).not_to match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/)
    expect(hash.name).not_to match(/^[a-zA-Z\s]{10,20}$/)
    expect(hash.pwd1).not_to match(/^([a-zA-Z]?\d){5,10}$/)
    expect(hash.age).not_to match(/^\d+$/)
    expect(hash.euros).not_to match(/^\d+$/)
    expect(hash.reports.to_s!='Weekely')
    expect(hash.reports.to_s!='Daily')
    expect(hash.username).not_to match(/^[a-z]{10,20}$/)
  end

  it "returns the hash with generated wrong value and string_set_not_allowed" do
    hash = NiceHash.generate(@hashopt, expected_errors: [:string_set_not_allowed])
    expect(hash.customer.to_s!='true')
    expect(hash.customer.to_s!='false')
    #todo: when DateTime is returning a valid date, verify if that's as expected
    #expect(hash.created).not_to match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/)
    expect(hash.name).not_to match(/^[a-zA-Z\s]{10,20}$/)
    expect(hash.pwd1).not_to match(/^([a-zA-Z]?\d){5,10}$/)
    expect(hash.age).not_to match(/^\d+$/)
    expect(hash.euros).not_to match(/^\d+$/)
    expect(hash.reports.to_s!='Weekely')
    expect(hash.reports.to_s!='Daily')
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
    my_hash.send_email = 'false'
    expect(my_hash.gen.email).to eq ""
  end
end
