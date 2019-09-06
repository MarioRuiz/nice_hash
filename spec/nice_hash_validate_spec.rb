require "nice_hash"

RSpec.describe NiceHash, "#validate" do
  it "validates the supplied hash" do
    values_to_validate = { :name => "Peter",
                          :address => "fnMuKW",
                          :city => "Dublin",
                          :products => [{ :name => "V4", :price => "344" }, { :name => "E", :price => "a" }] }
    expected_result = { :address => [:min_length, :length],
                       :products => [{ :name => [:min_length, :length] },
                                     { :name => [:min_length, :length], :price => [:value, :string_set_not_allowed] }] }

    validation = NiceHash.validate([@hash, :correct], values_to_validate)
    expect(validation).to eq expected_result
  end

  it "validates the supplied hash but not only patterns " do
    values_to_validate = { :name => "Peter",
                          :address => "fnMuKW",
                          :city => "Dublin",
                          :products => [{ :name => "V4", :price => "344" }, { :name => "E", :price => "a" }] }
    expected_result = { :address => [:min_length, :length],
                       :city => false,
                       :products => [{ :name => [:min_length, :length] },
                                     { :name => [:min_length, :length], :price => [:value, :string_set_not_allowed] }] }

    validation = NiceHash.validate([@hash, :correct], values_to_validate, only_patterns: false)
    expect(validation).to eq expected_result
  end

  it "validate patterns using Hash class" do
    values_to_validate = { :name => "Peter",
                          :address => "fnMuKW",
                          :city => "Dublin",
                          :products => [{ :name => "V4", :price => "344" }, { :name => "E", :price => "a" }] }
    expected_result = { :address => [:min_length, :length],
                       :products => [{ :name => [:min_length, :length] },
                                     { :name => [:min_length, :length], :price => [:value, :string_set_not_allowed] }] }

    validation = @hash.validate_patterns(:correct, values_to_validate)
    expect(validation).to eq expected_result
  end

  it "validates using Hash class" do
    values_to_validate = { :name => "Peter",
                          :address => "fnMuKW",
                          :city => "Dublin",
                          :products => [{ :name => "V4", :price => "344" }, { :name => "E", :price => "a" }] }
    expected_result = { :address => [:min_length, :length],
                       :city => false,
                       :products => [{ :name => [:min_length, :length] },
                                     { :name => [:min_length, :length], :price => [:value, :string_set_not_allowed] }] }

    validation = @hash.validate(:correct, values_to_validate)
    expect(validation).to eq expected_result
  end
end
