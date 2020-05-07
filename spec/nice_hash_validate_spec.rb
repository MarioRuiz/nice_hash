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

  it "validates all posibilities" do
    new_hash = @hashopt.generate
    expect(@hashopt.validate(new_hash)).to eq ({})
    expect(NiceHash.validate(@hashopt, new_hash)).to eq ({})
  end

  it 'validates using option same values' do
    hash = {[:pwd1, :pwd2]=>:'1-10:Ln'}
    expect(hash.validate({pwd1:'A', pwd2:'A'})).to eq ({})
  end
  it 'validates using option same values and not equal' do
    hash = {[:pwd1, :pwd2]=>:'1-10:Ln'}
    expect(hash.validate({pwd1:'A', pwd2:'V'})).to eq ({:pwd2=>"Not equal to pwd1"})
  end
  it 'validates Range wrong class' do
    hash = {age: 10..20}
    expect(hash.validate({age: 'A'})).to eq ({age: false})
  end
  it 'validates Range wrong value' do
    hash = {age: 10..20}
    expect(hash.validate({age: 50})).to eq ({age: false})
  end
  it 'validates DateTime with Date, Time or DateTime' do
    hash = {age: DateTime}
    expect(hash.validate({age: Date.new})).to eq ({})
    expect(hash.validate({age: DateTime.new})).to eq ({})
    expect(hash.validate({age: Time.new})).to eq ({})
  end
  it 'validates DateTime wrong value' do
    hash = {age: DateTime}
    expect(hash.validate({age: "aa"})).to eq ({age: false})
  end
  it 'validates Regexp wrong value' do
    hash = {age: /[\d]+/}
    expect(hash.validate({age: "aa"})).to eq ({age: false})
  end
  it 'validates Array of patterns' do
    hash = {age: ['1','2:N']}
    expect(hash.validate({age: "123"})).to eq ({})
  end
  it 'validates Array of patterns wrong value' do
    hash = {age: ['1','2:N']}
    expect(hash.validate({age: "12a"})).to eq ({age: false})
  end
  it 'validates Array' do
    hash = {age: ['1','2']}
    expect(hash.validate({age: ['1','2']})).to eq ({})
  end
  it 'validates Array wrong value' do
    hash = {age: [DateTime]}
    expect(hash.validate({age: [Date.new,'22']})).to eq ({:age=>[nil, {:age=>false}]})
  end
  it 'validates Array of Dates' do
    hash = {age: [DateTime]}
    expect(hash.validate({age: [Date.new, Date.new, Date.new]})).to eq ({})
  end
  it 'validates Array of Booleans' do
    hash = {age: [Boolean]}
    expect(hash.validate({age: [true, false, true]})).to eq ({})
  end
  it 'validates Array of Booleans wrong value' do
    hash = {age: [Boolean]}
    expect(hash.validate({age: [true, 'aa', true]})).to eq ({:age=>[nil, {:age=>false}]})
  end
  it 'validates Array of a pattern' do
    hash = { ages: [ :'1-99:N' ] }
    expect(hash.validate({age: ['1','2']})).to eq ({})
  end
  it 'validates Array of a pattern wrong value' do
    hash = { ages: [ :'1-99:N' ] }
    expect(hash.validate({ages: ['1','2a']})).to eq ({:ages => [[], [:value, :string_set_not_allowed]]})
  end

  if Gem::Version.new(RUBY_VERSION)>=Gem::Version.new('2.6')
    it 'validates infinite ranges' do
      hash = { age: 20.. }
      expect(hash.validate({age: 30})).to eq ({})
      expect(hash.validate({age: 10})).to eq ({age: false})
      expect(hash.validate({age: '20'})).to eq ({age: false})
    end
  end
end
