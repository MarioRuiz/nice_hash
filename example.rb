
require 'string_pattern'

require 'pp'
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
    sex: :"male|female", #any of these values
    display: true
}

if true
  wrong_min_length_hash=my_hash.generate(errors: :min_length)
  array=NiceHash.change_one_by_one(my_hash, wrong_min_length_hash)

  array.each {|hash_with_one_wrong_field|
    res=my_hash.validate_patterns(hash_with_one_wrong_field)
    puts "*"*30
    puts hash_with_one_wrong_field.inspect
    puts res.inspect
  }


  exit
end



wrong_min_length_hash = my_hash.generate(:correct, errors: :min_length)
array = NiceHash.change_one_by_one([my_hash, :correct], wrong_min_length_hash)

array.each {|hash_with_one_wrong_field|
#  res = my_hash.select_key(:correct).validate(hash_with_one_wrong_field, only_patterns: false)
  res = my_hash.validate(:correct,hash_with_one_wrong_field)
  puts "*"*30
  puts hash_with_one_wrong_field.inspect
  puts res.inspect
}

#pp a
