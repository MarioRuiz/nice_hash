# NiceHash

[![Gem Version](https://badge.fury.io/rb/nice_hash.svg)](https://rubygems.org/gems/nice_hash)

NiceHash creates hashes following certain patterns so your testing will be much easier.

You can easily generates all the hashes you want following the criteria you specify. 

Many other features coming to Hash class like the methods 'bury' or select_key, access the keys like methods: my_hash.my_key.other_key. You will be able to generate thousands of different hashes just declaring one and test easily APIs based on JSON for example.

To generate the strings following a pattern take a look at the documentation for string_pattern gem: https://github.com/MarioRuiz/string_pattern

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nice_hash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nice_hash

## Usage

Remember!! To generate the strings following a pattern take a look at the documentation for string_pattern gem: https://github.com/MarioRuiz/string_pattern

This is he Hash we will be using on our examples:

```ruby

require 'nice_hash'

my_hash={
    loginame: :"5-10:/xn/", 
    [:pwd1, :pwd2, :pwd3] => :"5-10:L/n/",
    name: :"10-20:T_/x/",
    draws: [
        {
            drawId: :"5:N",
            drawName: :"10:Ln",
            type: :"Weekely|Daily",
            owner: {
                default: 'admin',
                correct: :"20:L"
            }
        },
        {
            drawId: :"5:N",
            drawName: :"10:Ln",
            type: :"Weekely|Daily",
            owner: {
                default: 'admin',
                correct: :"20:L"
            }
        }
    ],
    zip: {default: '00000', correct: :'5:N'},
    address: "21 Doom Av",
    city: {
            default: "Madrid",
            correct: "London|Rome"
    },
    wagers: ['34AAB', 'dfffDD', '33499A'],
    country: {default: 'Spain', correct: ["Spain", "Iceland", "Serbia", "Denmark", "Canada", "Italy", "Austria"].join("|")}, #one of these values
    mobilePhone: {default: '(987)654321', correct: ['(', :'3:N', ')', :'6-8:N']},
    sex: :"male|female|other", #any of these values
    display: true
}
```

Explanations of the different fields:
  
    loginname: from 5 to 10 characters, mandatory to have lower letters and numbers
    pwd, pwd2, pwd3: will have the same value. The value from 5 to 10 chars, optional capital and lower letters, necessary to contain numbers
    name: from 10 to 20 chars. Optional national characters and space, necessary lower letters.
    drawId: 5 numbers
    drawName: 10 letters and/or numbers
    type: 'Weekely' or 'Daily'
    owner: correct: 20 letters
    zip: correct: 5 numbers
    city: correct: 'London' or 'Rome'
    country: correct: one of these values "Spain", "Iceland", "Serbia", "Denmark", "Canada", "Italy", "Austria"
    mobilePhone: correct: a sting pattern with one of the next: "(nnn) nnnnnn", "(nnn) nnnnnnn", "(nnn) nnnnnnnn"
    sex: 'male' or 'female' or 'other'

So in case you want to assign to a key a string pattern value like for example in loginame, you need to specify the string pattern as a symbol :"5-10:/xn/"

You can also supply an array of strings and string patterns, like on mobilePhone.correct: ['(', :'3:N', ')', :'6-8:N']}

Also you can specify to select one of the values you want by separating them with |, like for example on sex field: "male|female|other"

### How to access the different keys

You can access the keys of the hash like always, but now we added to the Hash class the posibility of accessing it using:

```ruby
    puts my_hash[:address] # like usually is done
    puts my_hash.address
    my_hash.address = '99 Danish Street' #assignment
    puts my_hash.loginame
    puts my_hash.mobilePhone.correct
    puts my_hash.draws[1].owner.correct
```
Also another way to access the different keys is by adding first underscore. 
By doing it this way we are avoiding the cases where already exists a method with the same name on Hash class, for example: zip, display, default, select... 

```ruby
    puts my_hash._address
    my_hash._address = '99 Danish Street' #assignment
    my_hash._display = false #assignment
    puts my_hash._loginame
    puts my_hash._mobilePhone._correct
    puts my_hash._draws[1]._owner._correct
    puts my_hash._zip.correct #you can mix both also
```

By using the string_pattern gem you can generate single strings following the specific pattern on the field:

```ruby
    puts my_hash.loginame.generate #>s93owuvkh
    puts my_hash.mobilePhone.correct.generate #>(039)5669558
    puts my_hash._zip._correct.gen # gen is an alias for generate method #>84584
```

### Filtering / Selecting an specific key on the hash and subhashes

In case you supply different possibilities to be used like for example on fields: owner, zip, city and mobilePhone, and you one to use a concrete one, use the method select_key

```ruby
    #using NiceHash class
    new_hash = NiceHash.select_key(my_hash, :correct)
    #using select_key method on Hash class
    new_hash = my_hash.select_key(:correct)
    default_hash = my_hash.select_key(:default)
```

On this example new_hash will contain: 

```ruby
{
    loginame: :"5-10:/xn/", 
    [:pwd1, :pwd2, :pwd3] => :"5-10:L/n/",
    name: :"10-20:T_/x/",
    draws: [
        {
            drawId: :"5:N",
            drawName: :"10:Ln",
            type: :"Weekely|Daily",
            owner: :"20:L"
        },
        {
            drawId: :"5:N",
            drawName: :"10:Ln",
            type: :"Weekely|Daily",
            owner: :"20:L"
        }
    ],
    zip: :'5:N',
    address: "21 Doom Av",
    city: "London|Rome",
    wagers: ['34AAB', 'dfffDD', '33499A'],
    country: ["Spain", "Iceland", "Serbia", "Denmark", "Canada", "Italy", "Austria"].join("|"), #one of these values
    mobilePhone: ['(', :'3:N', ')', :'6-8:N'],
    sex: :"male|female|other", #any of these values
    display: true
}
```

### How to generate the hash with the criteria we want

You can use the 'generate' method and everytime will be generated a different hash with different values.

Remember you can filter/select by a hash key

Using the NiceHash class:
```ruby
#without filtering
new_hash = NiceHash.generate(my_hash)
#filtering by a key passing the key on parameters
new_hash = NiceHash.generate(my_hash, :correct)
```

Using Hash class (you can use the alias 'gen' for 'generate'): 
```ruby
#without filtering
new_hash = my_hash.generate
#filtering by a key passing the key on parameters
new_hash = my_hash.generate(:correct)
#filtering by a key using select_key method
new_hash = my_hash.select_key(:correct).generate
```


In case of filtering by :correct new_hash would have a value like this for example:

```ruby
{:loginame=>"s45x029o",
 :pwd1=>"E6hz9YS7",
 :pwd2=>"E6hz9YS7",
 :pwd3=>"E6hz9YS7",
 :name=>"OyTQNfEyPOzVYMxPym",
 :draws=>
  [{:drawId=>"54591",
    :drawName=>"cr5Q7pq4G8",
    :type=>"Weekely",
    :owner=>"nKEasYWInPGJxxElBZUB"},
   {:drawId=>"73307",
    :drawName=>"FnHPM4CsRC",
    :type=>"Weekely",
    :owner=>"cNGpHDhDLcxSFbOGqvNy"}],
 :zip=>"47537",
 :address=>"21 Doom Av",
 :city=>"London",
 :wagers=>["34AAB", "dfffDD", "33499A"],
 :country=>"Denmark",
 :mobilePhone=>"(707)8782080",
 :sex=>"male",
 :display=>true}
```

In case no filtering you will get all the values for all keys

### How to generate the hash with wrong values for the string patterns specified on the hash

We can generate wrong values passing the keyword argument: expected_errors (alias: errors)

The possible values you can specify is one or more of these ones: :length, :min_length, :max_length, :value, :required_data, :excluded_data, :string_set_not_allowed

    :length: wrong length, minimum or maximum
    :min_length: wrong minimum length
    :max_length: wrong maximum length
    :value: wrong resultant value
    :required_data: the output string won't include all necessary required data. It works only if required data supplied on the pattern.
    :excluded_data: the resultant string will include one or more characters that should be excluded. It works only if excluded data supplied on the pattern.
    :string_set_not_allowed: it will include one or more characters that are not supposed to be on the string.

Examples:

```ruby
wrong_values = my_hash.generate(:correct, expected_errors: [:value])

wrong_max_length = my_hash.generate(:correct, errors: :max_length)

wrong_min_length = my_hash.generate(:correct, expected_errors: :min_length)

wrong_min_length = my_hash.select_key(:correct).generate(errors: :min_length)

valid_values = my_hash.generate(:correct)
```

On this example wrong_min_length will contain something like:

```ruby
{:loginame=>"0u",
 :pwd1=>"4XDx",
 :pwd2=>"4XDx",
 :pwd3=>"4XDx",
 :name=>"bU",
 :draws=>
  [{:drawId=>"", :drawName=>"P03AgdMqV", :type=>"Dail", :owner=>"dYzLRMCnVc"},
   {:drawId=>"", :drawName=>"qw", :type=>"Dail", :owner=>"zkHhTEzM"}],
 :zip=>"7168",
 :address=>"21 Doom Av",
 :city=>"Rom",
 :wagers=>["34AAB", "dfffDD", "33499A"],
 :country=>"Spai",
 :mobilePhone=>"(237)17640431",
 :sex=>"mal",
 :display=>true}
```

### Return the select_fields or the pattern_fields

If you need a list of select fields or pattern fields that exist on your hash you can use the methods: select_fields and pattern_fields

It will return an array with all the fields found. On every entry of the array you will see keys to the field.

```ruby
all_select_fields = my_hash.select_fields
select_fields_on_correct = my_hash.select_fields(:correct)

all_pattern_fields = my_hash.pattern_fields
pattern_fields_on_correct = my_hash.pattern_fields(:correct)
```

all_select_fields contains: 

```ruby
[[:draws, 0, :type],
 [:draws, 1, :type],
 [:city, :correct],
 [:country, :correct],
 [:sex]]
```

select_fields_on_correct contains: 

```ruby
[[:draws, 0, :type], 
 [:draws, 1, :type], 
 [:city], 
 [:country], 
 [:sex]]
```

all_pattern_fields contains: 

```ruby
[[:loginame],
 [[:pwd1, :pwd2, :pwd3]],
 [:name],
 [:draws, 0, :drawId],
 [:draws, 0, :drawName],
 [:draws, 0, :owner, :correct],
 [:draws, 1, :drawId],
 [:draws, 1, :drawName],
 [:draws, 1, :owner, :correct],
 [:zip, :correct],
 [:mobilePhone, :correct]]
```

pattern_fields_on_correct contains: 

```ruby
[[:loginame],
 [[:pwd1, :pwd2, :pwd3]],
 [:name],
 [:draws, 0, :drawId],
 [:draws, 0, :drawName],
 [:draws, 0, :owner],
 [:draws, 1, :drawId],
 [:draws, 1, :drawName],
 [:draws, 1, :owner],
 [:zip],
 [:mobilePhone]]
```


#### dig and bury Hash methods
In case you want to access the values on a hash structure by using the key array location, you can use the 'dig' method on the Hash class:

```ruby
min_length_error = my_hash.generate :correct, errors: :min_length

patterns = my_hash.pattern_fields :correct

patterns.each{|key|
  if key[0].kind_of?(Array) # same values, like in pwd1, pwd2 and pwd3
    puts "#{key} same values"
    value = min_length_error.dig(key[0][0])
  else
    value = min_length_error.dig(*key)
  end
  
  pattern = my_hash.select_key(:correct).dig(*key)
  puts "the value: '#{value}' was generated from the key: #{key} with pattern: #{pattern}"
}
```

This returns something like: 

```
the value: '5z' was generated from the key: [:loginame] with pattern: 5-10:/xn/
[[:pwd1, :pwd2, :pwd3]] same values
the value: '5' was generated from the key: [[:pwd1, :pwd2, :pwd3]] with pattern: 5-10:L/n/
the value: 'KshiYAmp' was generated from the key: [:name] with pattern: 10-20:T_/x/
the value: '722' was generated from the key: [:draws, 0, :drawId] with pattern: 5:N
the value: '4' was generated from the key: [:draws, 0, :drawName] with pattern: 10:Ln
the value: 'jhVZkII' was generated from the key: [:draws, 0, :owner] with pattern: 20:L
the value: '260' was generated from the key: [:draws, 1, :drawId] with pattern: 5:N
the value: 'ssty8hlnJ' was generated from the key: [:draws, 1, :drawName] with pattern: 10:Ln
the value: 'zPvcwOyyXvWSgNHsuv' was generated from the key: [:draws, 1, :owner] with pattern: 20:L
the value: '242' was generated from the key: [:zip] with pattern: 5:N
the value: '(91)7606' was generated from the key: [:mobilePhone] with pattern: ["(", :"3:N", ")", :"6-8:N"]
```

Ruby Hash class doesn't have a method to allocate a value using the key array location so we added to Hash class a method for that purpose, the 'bury' method.

```ruby
default_values = my_hash.generate :default

default_values.bury([:draws, 0, :drawName], "FirstDraw")
```

After using the bury method default_values will contain:

```ruby
{:loginame=>"i0v2jy",
 :pwd1=>"x33exx",
 :pwd2=>"x33exx",
 :pwd3=>"x33exx",
 :name=>"HdmsjLxlEgYIFY",
 :draws=>
  [{:drawId=>"12318",
    :drawName=>"FirstDraw",
    :type=>"Weekely",
    :owner=>"admin"},
   {:drawId=>"18947",
    :drawName=>"LPgf2ZQvkG",
    :type=>"Weekely",
    :owner=>"admin"}],
 :zip=>"00000",
 :address=>"21 Doom Av",
 :city=>"Madrid",
 :wagers=>["34AAB", "dfffDD", "33499A"],
 :country=>"Spain",
 :mobilePhone=>"(987)654321",
 :sex=>"male",
 :display=>true}
```

### Validating hashes

If you have a Hash that should follow the patterns you specified (in this example declared on my_hash) and you want to validate, then use the 'validate' method.

This is particulary useful to test REST APIs responses in JSON

If we have a hash with these values:

```ruby
{:loginame=>"rdewvqur",
 :pwd1=>"d3ulo",
 :pwd2=>"d3ulo",
 :pwd3=>"d3ulo",
 :name=>"LTqVKxxFCTqpkdjFkxU",
 :draws=>
  [{:drawId=>"54a43",
    :drawName=>"h3F24yjMWp",
    :type=>"Daily",
    :owner=>"abIZMRxTDsWjQcpdspZt"},
   {:drawId=>"13010",
    :drawName=>"NurCEAtE1M",
    :type=>"Daily",
    :owner=>"vSVoqtSzHkbvRNyJoYGz"}],
 :zip=>"30222",
 :address=>"21 Doom Av",
 :city=>"New York",
 :wagers=>["34AAB", "dfffDD", "33499A"],
 :country=>"Iceland",
 :mobilePhone=>"(441)97037845",
 :sex=>"male",
 :display=>true}
```

To validate those values taking in consideration was is stated on my_hash:

```ruby
results_all_fields = my_hash.validate :correct, values

results_pattern_fields = my_hash.validate_patterns :correct, values
```

results_all_fields will contain all the validation errors:

```ruby
{:loginame=>[:value, :required_data],
 :draws=>[{:drawId=>[:value, :string_set_not_allowed]}],
 :city=>false}
```

and results_pattern_fields will contain only the validation errors for the fields containing patterns:

```ruby
{:loginame=>[:value, :required_data],
 :draws=>[{:drawId=>[:value, :string_set_not_allowed]}]}
```

The possible validation values returned:

    :length: wrong length, minimum or maximum
    :min_length: wrong minimum length
    :max_length: wrong maximum length
    :value: wrong resultant value
    :required_data: the output string won't include all necessary required data. It works only if required data supplied on the pattern.
    :excluded_data: the resultant string will include one or more characters that should be excluded. It works only if excluded data supplied on the pattern.
    :string_set_not_allowed: it will include one or more characters that are not supposed to be on the string.


### Change only one value at a time and return an Array of Hashes

Let's guess we need to test a typical registration REST service and the service has many fields with many validations but we want to test it one field at a time.

Then the best thing you can do is to use the method NiceHash.change_one_by_one.


```ruby

wrong_min_length_hash = my_hash.generate(:correct, errors: :min_length)

array_of_hashes = NiceHash.change_one_by_one([my_hash, :correct], wrong_min_length_hash)

array_of_hashes.each {|hash_with_one_wrong_field|
  #Here your code to send through http the JSON data stored in hash_with_one_wrong_field
  
  #if you want to know which field is the one that is wrong:
  res = my_hash.validate(:correct, hash_with_one_wrong_field)
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marioruiz/nice_hash.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


