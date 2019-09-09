SP_ADD_TO_RUBY = true if !defined?(SP_ADD_TO_RUBY)
#todo: add SP_USE_NESTED_KEYS = true

require_relative "nice/hash/add_to_ruby" if SP_ADD_TO_RUBY
require_relative "nice/hash/change_one_by_one"
require_relative "nice/hash/compare_structure"
require_relative "nice/hash/delete_nested"
require_relative "nice/hash/generate"
require_relative "nice/hash/get_all_keys"
require_relative "nice/hash/get_values"
require_relative "nice/hash/nice_filter"
require_relative "nice/hash/pattern_fields"
require_relative "nice/hash/select_fields"
require_relative "nice/hash/select_key"
require_relative "nice/hash/set_nested"
require_relative "nice/hash/set_values"
require_relative "nice/hash/transtring"
require_relative "nice/hash/validate"


require "string_pattern"

###########################################################################
# NiceHash creates hashes following certain patterns so your testing will be much easier.
# You can easily generates all the hashes you want following the criteria you specify.
# Many other features coming to Hash class like the methods 'bury' or select_key, access the keys like methods: my_hash.my_key.other_key.
# You will be able to generate thousands of different hashes just declaring one and test easily APIs based on JSON for example.
# To generate the strings following a pattern take a look at the documentation for string_pattern gem: https://github.com/MarioRuiz/string_pattern
# This is the Hash we will be using on the examples declared on the methods source code documentation:
#   my_hash={
#     name: 'Peter',
#     address: {wrong: '#$$$$$', correct: :'10-30:L_'},
#     city: {wrong: 'Germany', correct: :'Madrid|Barcelona|London|Akureyri'},
#     products: [
#       {
#         name: :'10:Ln',
#         price: {wrong: '-20', correct: :'1-10:N'}
#       },
#       {
#         name: :'10:Ln',
#         price: {wrong: '-20', correct: :'1-10:N'}
#       },
#     ]
#   }
###########################################################################
class NiceHash
  class << self
    attr_reader :values
  end
  @values = {}
end
