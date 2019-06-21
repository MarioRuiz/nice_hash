SP_ADD_TO_RUBY = true if !defined?(SP_ADD_TO_RUBY)
require_relative "nice/hash/add_to_ruby" if SP_ADD_TO_RUBY

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

  ###########################################################################
  # It will filter the hash by the key specified on select_hash_key.
  # In case a subhash specified on a value it will be selected only the value of the key specified on select_hash_key
  #
  # input:
  #   pattern_hash: (Hash) Hash we want to select specific keys
  #   select_hash_key: (key value) The key we want to select on the subhashes
  # output: (Hash)
  #   The same hash but in case a subhash specified on a value it will be selected only the value of the key specified on select_hash_key
  # example:
  #   new_hash = NiceHash.select_key(my_hash, :wrong)
  #   #> {:name=>"Peter", :address=>"\#$$$$$", :city=>"Germany", :products=> [{:name=>:"10:Ln", :price=>"-20"}, {:name=>:"10:Ln", :price=>"-20"}]}
  # Using it directly on Hash class, select_key(select_hash_key):
  #   new_hash = my_hash.select_key(:wrong)
  ###########################################################################
  def NiceHash.select_key(pattern_hash, select_hash_key)
    hashv = Hash.new()

    if pattern_hash.kind_of?(Hash) and pattern_hash.size > 0
      pattern_hash.each { |key, value|
        if value.kind_of?(Hash)
          if value.keys.include?(select_hash_key)
            value = value[select_hash_key]
          else
            value = NiceHash.select_key(value, select_hash_key)
          end
        end
        if value.kind_of?(Array)
          array_pattern = false
          value.each { |v|
            if (v.kind_of?(String) or v.kind_of?(Symbol)) and StringPattern.analyze(v, silent: true).kind_of?(StringPattern::Pattern)
              hashv[key] = value
              array_pattern = true
              break
            end
          }
          unless array_pattern
            value_ret = Array.new
            value.each { |v|
              ret = NiceHash.select_key(v, select_hash_key)
              value_ret << ret
            }
            hashv[key] = value_ret
          end
        else
          hashv[key] = value
        end
      }
    else
      return pattern_hash
    end
    return hashv
  end

  ###########################################################################
  # It will search for the keys supplied and it will set the value specified
  #
  # input:
  #   hash_array: (Hash/Array) Hash/Array we want to search on
  #   hash_values: (Hash) Hash that contains the keys and values to set
  # output: (Hash/Array)
  #   The same hash/array but with the values we specifed changed
  # example:
  #   new_hash = NiceHash.set_values(my_hash, {city: 'London', price: '1000'})
  #   #> {:name=>"Peter", :address=>"\#$$$$$", :city=>"London", :products=> [{:name=>:"10:Ln", :price=>"1000"}, {:name=>:"10:Ln", :price=>"1000"}]}
  # Using it directly on Hash class, set_values(hash_values):
  #   new_hash = my_hash.set_values({city: 'London', price: '1000'})
  ###########################################################################
  def NiceHash.set_values(hash_array, hash_values)
    hashv = Hash.new()
    if hash_array.is_a?(Hash) and hash_array.size > 0
      hash_array.each do |k, v|
        if hash_values.keys.include?(k)
          hashv[k] = hash_values[k]
        elsif v.is_a?(Array)
          hashv[k] = NiceHash.set_values(v, hash_values)
        elsif v.is_a?(Hash)
          hashv[k] = NiceHash.set_values(v, hash_values)
        else
          hashv[k] = v
        end
      end
      hash_values.each do |k, v|
        hashv = NiceHash.set_nested(hashv, k, v, true) if k.is_a?(Hash)
      end
      return hashv
    elsif hash_array.is_a?(Array) and hash_array.size > 0
      hashv = Array.new
      hash_array.each do |r|
        hashv << NiceHash.set_values(r, hash_values)
      end
      return hashv
    else
      return hash_array
    end
  end

  ###########################################################################
  # It will return an array of the keys where we are using string patterns.
  #
  # input:
  #   pattern_hash: (Hash) Hash we want to get the pattern_fields
  #   select_hash_key: (key value) (optional) The key we want to select on the subhashes
  # output: (Array)
  #   Array of the kind: [ [key], [key, subkey, subkey]  ]
  #   Each value of the array can be used as parameter for the methods: dig, bury
  # examples:
  #   NiceHash.pattern_fields(my_hash)
  #   #> [
  #       [:address, :correct],
  #       [:products, 0, :name],
  #       [:products, 0, :price, :correct],
  #       [:products, 1, :name],
  #       [:products, 1, :price, :correct]
  #      ]
  #   NiceHash.pattern_fields(my_hash, :correct)
  #   #> [
  #       [:address],
  #       [:products, 0, :name],
  #       [:products, 0, :price],
  #       [:products, 1, :name],
  #       [:products, 1, :price]
  #      ]
  # Using it directly on Hash class, pattern_fields(*select_hash_key) (alias: patterns):
  #   my_hash.pattern_fields
  #   my_hash.pattern_fields(:correct)
  #   my_hash.patterns(:correct)
  ###########################################################################
  def NiceHash.pattern_fields(pattern_hash, *select_hash_key)
    pattern_fields = Array.new

    if pattern_hash.kind_of?(Hash) and pattern_hash.size > 0
      pattern_hash.each { |key, value|
        key = [key]
        if value.kind_of?(Hash)
          if select_hash_key.size == 1 and value.keys.include?(select_hash_key[0])
            value = value[select_hash_key[0]]
          else
            res = NiceHash.pattern_fields(value, *select_hash_key)
            if res.size > 0
              res.each { |r|
                pattern_fields << (r.unshift(key)).flatten
              }
            end
            next
          end
        end
        if value.kind_of?(String)
          if StringPattern.optimistic and value.to_s.scan(/^!?\d+-?\d*:.+/).size > 0
            pattern_fields << key
          end
        elsif value.kind_of?(Symbol)
          if value.to_s.scan(/^!?\d+-?\d*:.+/).size > 0
            pattern_fields << key
          end
        elsif value.kind_of?(Array)
          array_pattern = false
          value.each { |v|
            if (v.kind_of?(String) or v.kind_of?(Symbol)) and StringPattern.analyze(v, silent: true).kind_of?(StringPattern::Pattern)
              pattern_fields << key
              array_pattern = true
              break
            end
          }
          unless array_pattern
            i = 0
            value.each { |v|
              res = NiceHash.pattern_fields(v, *select_hash_key)
              if res.size > 0
                res.each { |r|
                  pattern_fields << (r.unshift(i).unshift(key)).flatten
                }
              end
              i += 1
            }
          end
        end
      }
    end

    return pattern_fields
  end

  ###########################################################################
  # It will return an array of the keys where we are using select values of the kind: "value1|value2|value3".
  #
  # input:
  #   pattern_hash: (Hash) Hash we want to get the select_fields
  #   select_hash_key: (key value) (optional) The key we want to select on the subhashes
  # output: (Array)
  #   Array of the kind: [ [key], [key, subkey, subkey]  ]
  #   Each value of the array can be used as parameter for the methods: dig, bury
  # examples:
  #   NiceHash.select_fields(my_hash)
  #   #> [[:city, :correct]]
  #   NiceHash.select_fields(my_hash, :correct)
  #   #> [[:city]]
  # Using it directly on Hash class, select_fields(*select_hash_key):
  #   my_hash.select_fields
  #   my_hash.select_fields(:correct)
  ###########################################################################
  def NiceHash.select_fields(pattern_hash, *select_hash_key)
    select_fields = Array.new

    if pattern_hash.kind_of?(Hash) and pattern_hash.size > 0
      pattern_hash.each { |key, value|
        key = [key]
        if value.kind_of?(Hash)
          if select_hash_key.size == 1 and value.keys.include?(select_hash_key[0])
            value = value[select_hash_key[0]]
          else
            res = NiceHash.select_fields(value, *select_hash_key)
            if res.size > 0
              res.each { |r|
                select_fields << (r.unshift(key)).flatten
              }
            end
            next
          end
        end
        if value.kind_of?(String)
          if StringPattern.optimistic and value.to_s.scan(/^([\w\s\-]+\|)+[\w\s\-]+$/).size > 0
            select_fields << key
          end
        elsif value.kind_of?(Symbol)
          if value.to_s.scan(/^([\w\s\-]+\|)+[\w\s\-]+$/).size > 0
            select_fields << key
          end
        elsif value.kind_of?(Array)
          array_pattern = false
          value.each { |v|
            if (v.kind_of?(String) or v.kind_of?(Symbol)) and StringPattern.analyze(v, silent: true).kind_of?(StringPattern::Pattern)
              array_pattern = true
              break
            end
          }
          unless array_pattern
            i = 0
            value.each { |v|
              res = NiceHash.select_fields(v, *select_hash_key)
              if res.size > 0
                res.each { |r|
                  select_fields << (r.unshift(i).unshift(key)).flatten
                }
              end
              i += 1
            }
          end
        end
      }
    end

    return select_fields
  end

  ###########################################################################
  # It will generate a new hash with the values generated from the string patterns and select fields specified.
  # In case supplied select_hash_key and a subhash specified on a value it will be selected only the value of the key specified on select_hash_key
  # If expected_errors specified the values will be generated with the specified errors.
  # input:
  #   pattern_hash: (Hash) Hash we want to use to generate the values
  #   select_hash_key: (key value) (optional) The key we want to select on the subhashes
  #   expected_errors: (Array) (optional) (alias: errors) To generate the string patterns with the specified errors.
  #     The possible values you can specify is one or more of these ones:
  #       :length: wrong length, minimum or maximum
  #       :min_length: wrong minimum length
  #       :max_length: wrong maximum length
  #       :value: wrong resultant value
  #       :required_data: the output string won't include all necessary required data. It works only if required data supplied on the pattern.
  #       :excluded_data: the resultant string will include one or more characters that should be excluded. It works only if excluded data supplied on the pattern.
  #       :string_set_not_allowed: it will include one or more characters that are not supposed to be on the string.
  # output: (Hash)
  #   The Hash with the select_hash_key selected and the values generated from the string patterns and select fields specified.
  # examples:
  #   new_hash = NiceHash.generate(my_hash)
  #   #> {:name=>"Peter",
  #       :address=>{:wrong=>"\#$$$$$", :correct=>"KZPCzxsWGMLqonesu wbqH"},
  #       :city=>{:wrong=>"Germany", :correct=>"Barcelona"},
  #       :products=> [
  #         {:name=>"gIqkWygmVm", :price=>{:wrong=>"-20", :correct=>"34338330"}},
  #         {:name=>"CK68VLIcYf", :price=>{:wrong=>"-20", :correct=>"616066520"}}
  #       ]
  #      }
  #   new_hash = NiceHash.generate(my_hash, :correct)
  #   #> {:name=>"Peter",
  #       :address=>"juQeAVZjIuWBPsE",
  #       :city=>"Madrid",
  #       :products=> [
  #         {:name=>"G44Ilr0puV", :price=>"477813"},
  #         {:name=>"v6ojs79LOp", :price=>"74820"}
  #       ]
  #      }
  #   new_hash = NiceHash.generate(my_hash, :correct, expected_errors: [:min_length])
  #   #> {:name=>"Peter",
  #       :address=>"ZytjefJ",
  #       :city=>"Madri",
  #       :products=>[
  #         {:name=>"cIBrzeO", :price=>""},
  #         {:name=>"5", :price=>""}
  #        ]
  #       }
  # Using it directly on Hash class, generate(select_hash_key=nil, expected_errors: []) (alias: gen):
  #   new_hash = my_hash.generate
  #   new_hash = my_hash.gen(:correct)
  #   new_hash = my_hash.generate(:correct, errors: [:min_length])
  ###########################################################################
  def NiceHash.generate(pattern_hash, select_hash_key = nil, expected_errors: [], **synonyms)
    hashv = Hash.new()
    same_values = Hash.new()
    expected_errors = synonyms[:errors] if synonyms.keys.include?(:errors)
    if expected_errors.kind_of?(Symbol)
      expected_errors = [expected_errors]
    end

    if pattern_hash.kind_of?(Hash) and pattern_hash.size > 0
      pattern_hash.each { |key, value|
        if key.kind_of?(Array)
          same_values[key[0]] = key.dup
          same_values[key[0]].shift
          key = key[0]
        end
        if value.kind_of?(Hash)
          if value.keys.include?(select_hash_key)
            value = value[select_hash_key]
          else
            value = NiceHash.generate(value, select_hash_key, expected_errors: expected_errors)
          end
        end
        if value.kind_of?(String) or value.kind_of?(Symbol)
          if ((StringPattern.optimistic and value.kind_of?(String)) or value.kind_of?(Symbol)) and value.to_s.scan(/^!?\d+-?\d*:.+/).size > 0
            hashv[key] = StringPattern.generate(value, expected_errors: expected_errors)
          elsif ((StringPattern.optimistic and value.kind_of?(String)) or value.kind_of?(Symbol)) and value.to_s.scan(/^([\w\s\-]+\|)+[\w\s\-]+$/).size > 0
            if expected_errors.include?(:min_length) or (expected_errors.include?(:length) and rand.round == 0)
              min = value.to_s.split("|").min { |a, b| a.size <=> b.size }
              hashv[key] = min[0..-2] unless min == ""
            end
            if !hashv.keys.include?(key) and (expected_errors.include?(:max_length) or expected_errors.include?(:length))
              max = value.to_s.split("|").max { |a, b| a.size <=> b.size }
              hashv[key] = max + max[-1]
            end
            if expected_errors.include?(:value) or
               expected_errors.include?(:string_set_not_allowed) or
               expected_errors.include?(:required_data)
              if hashv.keys.include?(key)
                v = hashv[key]
              else
                v = value.to_s.split("|").sample
              end
              unless expected_errors.include?(:string_set_not_allowed)
                v = StringPattern.generate(:"#{v.size}:[#{value.to_s.split("|").join.split(//).uniq.join}]")
                hashv[key] = v unless value.to_s.split("|").include?(v)
              end
              unless hashv.keys.include?(key)
                one_wrong_letter = StringPattern.generate(:"1:LN$[%#{value.to_s.split("|").join.split(//).uniq.join}%]")
                v[rand(v.size)] = one_wrong_letter
                hashv[key] = v unless value.to_s.split("|").include?(v)
              end
            end
            unless hashv.keys.include?(key)
              hashv[key] = value.to_s.split("|").sample
            end
          else
            hashv[key] = value
          end
        elsif value.kind_of?(Array)
          array_pattern = false
          value.each { |v|
            if (v.kind_of?(String) or v.kind_of?(Symbol)) and StringPattern.analyze(v, silent: true).kind_of?(StringPattern::Pattern)
              hashv[key] = StringPattern.generate(value, expected_errors: expected_errors)
              array_pattern = true
              break
            end
          }
          unless array_pattern
            value_ret = Array.new
            value.each { |v|
              if v.is_a?(Hash)
                ret = NiceHash.generate(v, select_hash_key, expected_errors: expected_errors)
              else
                ret = NiceHash.generate({doit: v}, select_hash_key, expected_errors: expected_errors)
                ret = ret[:doit] if ret.is_a?(Hash) and ret.key?(:doit)
              end
              ret = v if ret.kind_of?(Hash) and ret.size == 0 
              value_ret << ret
            }
            hashv[key] = value_ret
          end
        elsif value.kind_of?(Range)
          if expected_errors.empty?
            hashv[key] = rand(value)  
          else
            hashv[key] = rand(value)
            expected_errors.each do |er|
              if er == :min_length
                hashv[key] = rand((value.first-value.last)..value.first-1)
              elsif er == :max_length
                hashv[key] = rand((value.last+1)..(value.last*2))
              elsif er == :length
                if rand.round==1
                  hashv[key] = rand((value.first-value.last)..value.first-1)
                else
                  hashv[key] = rand((value.last+1)..(value.last*2))
                end
              elsif er == :value
                hashv[key] = :"1-10:N/L/".gen
              end
            end
          end
        elsif value.kind_of?(Class) and value == DateTime
          if expected_errors.empty?
            hashv[key] = Time.now.stamp
          else
            hashv[key] = Time.now.stamp
            expected_errors.each do |er|
              if er == :min_length
                hashv[key] = hashv[key].chop
              elsif er == :max_length
                hashv[key] = hashv[key] + "Z"
              elsif er == :length
                if rand.round==1
                  hashv[key] = hashv[key].chop
                else
                  hashv[key] = hashv[key] + "Z"
                end
              elsif er == :value
                hashv[key][rand(hashv[key].size-1)] = '1:L'.gen
              end
            end
          end
        elsif value.kind_of?(Module) and value == Boolean
          if expected_errors.empty?
            hashv[key] = (rand.round == 0)
          else
            hashv[key] = (rand.round == 0)
            expected_errors.each do |er|
              if er == :value
                hashv[key] = '1-10:L'.gen
              end
            end
          end
        elsif value.kind_of?(Proc)
          hashv[key] = value.call
        elsif value.kind_of?(Regexp)
          hashv[key] = value.generate(expected_errors: expected_errors)
        else
          hashv[key] = value
        end

        if same_values.include?(key)
          same_values[key].each { |k|
            hashv[k] = hashv[key]
          }
        end

        @values = hashv
      }
    end

    return hashv
  end

  ###########################################################################
  # Validates a given values_hash_to_validate with string patterns and select fields from pattern_hash
  # input:
  #   patterns_hash:
  #     (Hash) Hash where we have defined the patterns to follow.
  #     (Array) In case of array supplied, the pair: [pattern_hash, select_hash_key]. select_hash_key will filter the hash by that key
  #   values_hash_to_validate: (Hash) Hash of values to validate
  #   only_patterns: (TrueFalse) (by default true) If true it will validate only the patterns and not the other fields
  # output: (Hash)
  #   A hash with the validation results. It will return only the validation errors so in case no validation errors found, empty hash.
  #   The keys of the hash will be the keys of the values hash with the validation error.
  #   The value in case of a pattern, will be an array with one or more of these possibilities:
  #       :length: wrong length, minimum or maximum
  #       :min_length: wrong minimum length
  #       :max_length: wrong maximum length
  #       :value: wrong resultant value
  #       :required_data: the output string won't include all necessary required data. It works only if required data supplied on the pattern.
  #       :excluded_data: the resultant string will include one or more characters that should be excluded. It works only if excluded data supplied on the pattern.
  #       :string_set_not_allowed: it will include one or more characters that are not supposed to be on the string.
  #   The value in any other case it will be false if the value is not corresponding to the expected.
  # examples:
  #   values_to_validate = {:name=>"Peter",
  #                         :address=>"fnMuKW",
  #                         :city=>"Dublin",
  #                         :products=>[{:name=>"V4", :price=>"344"}, {:name=>"E", :price=>"a"}]
  #                        }
  #   results = NiceHash.validate([my_hash, :correct], values_to_validate)
  #   #> {:address=>[:min_length, :length],
  #       :products=> [{:name=>[:min_length, :length]},
  #                    {:name=>[:min_length, :length], :price=>[:value, :string_set_not_allowed]}
  #                   ]
  #      }
  #   results = NiceHash.validate([my_hash, :correct], values_to_validate, only_patterns: false)
  #   #> {:address=>[:min_length, :length],
  #       :city=>false,
  #       :products=> [{:name=>[:min_length, :length]},
  #                    {:name=>[:min_length, :length], :price=>[:value, :string_set_not_allowed]}
  #                   ]
  #      }
  # Using it directly on Hash class:
  #   validate(select_hash_key=nil, values_hash_to_validate) (alias: val)
  #   validate_patterns(select_hash_key=nil, values_hash_to_validate)
  #
  #   results = my_hash.validate_patterns(:correct, values_to_validate)
  #   results = my_hash.validate(:correct, values_to_validate)
  ###########################################################################
  def NiceHash.validate(patterns_hash, values_hash_to_validate, only_patterns: true)
    if patterns_hash.kind_of?(Array)
      pattern_hash = patterns_hash[0]
      select_hash_key = patterns_hash[1]
    elsif patterns_hash.kind_of?(Hash)
      pattern_hash = patterns_hash
      select_hash_key = nil
    else
      puts "NiceHash.validate wrong pattern_hash supplied #{patterns_hash.inspect}"
      return { error: :error }
    end
    values = values_hash_to_validate
    results = {}
    same_values = {}
    if pattern_hash.kind_of?(Hash) and pattern_hash.size > 0
      pattern_hash.each { |key, value|
        if key.kind_of?(Array)
          same_values[key[0]] = key.dup
          same_values[key[0]].shift
          key = key[0]
        end
        if value.kind_of?(Hash)
          if !select_hash_key.nil? and value.keys.include?(select_hash_key)
            value = value[select_hash_key]
          elsif values.keys.include?(key) and values[key].kind_of?(Hash)
            res = NiceHash.validate([value, select_hash_key], values[key], only_patterns: only_patterns)
            results[key] = res if res.size > 0
            next
          end
        end

        if values.keys.include?(key)
          if value.kind_of?(String) or value.kind_of?(Symbol)
            if ((StringPattern.optimistic and value.kind_of?(String)) or value.kind_of?(Symbol)) and value.to_s.scan(/^!?\d+-?\d*:.+/).size > 0
              res = StringPattern.validate(pattern: value, text: values[key])
              results[key] = res if res.size > 0
            elsif !only_patterns and ((StringPattern.optimistic and value.kind_of?(String)) or value.kind_of?(Symbol)) and value.to_s.scan(/^([\w\s\-]+\|)+[\w\s\-]+$/).size > 0
              results[key] = false unless value.to_s.split("|").include?(values[key])
            elsif !only_patterns
              results[key] = false unless value.to_s == values[key].to_s
            end
          elsif value.kind_of?(Range)
            if values[key].class != value.first.class or values[key].class != value.last.class
              results[key] = false
            elsif values[key] < value.first or values[key] > value.last
              results[key] = false
            end
          elsif value.kind_of?(Class) and value == DateTime
            if values[key].size == 24
              d = Date.strptime(values[key], '%Y-%m-%dT%H:%M:%S.%LZ') rescue results[key] = false
            else
              results[key] = false
            end
          elsif value.kind_of?(Module) and value == Boolean
            results[key] = false unless values[key].is_a?(Boolean)
          elsif value.kind_of?(Regexp)
            rex = Regexp.new("^#{value}$")
            unless values[key].match?(rex)
              results[key] = false
            end
          elsif value.kind_of?(Array)
            array_pattern = false
            complex_data = false
            value.each { |v|
              if (v.kind_of?(String) or v.kind_of?(Symbol)) and StringPattern.analyze(v, silent: true).kind_of?(StringPattern::Pattern)
                res = StringPattern.validate(pattern: value, text: values[key])
                results[key] = res if res == false
                array_pattern = true
                break
              elsif v.kind_of?(Hash) or v.kind_of?(Array) or v.kind_of?(Struct)
                complex_data = true
                break
              end
            }
            unless array_pattern or results.include?(key)
              if value.size == 1 and values[key].size > 1
                # for the case value == ['Ford|Newton|Seat'] and values == ['Ford', 'Newton', 'Ford']
                i= 0
                values[key].each do |v|
                  if value[0].is_a?(Hash)
                    res = NiceHash.validate([value[0], select_hash_key], v, only_patterns: only_patterns)
                  else
                    # for the case {cars: ['Ford|Newton|Seat']}
                    res = NiceHash.validate([{key => value[0]}, select_hash_key], {key => v}, only_patterns: only_patterns)
                    #res = {key => res[:doit]} if res.is_a?(Hash) and res.key?(:doit)
                    array_pattern = true
                  end
                  if res.size > 0
                    results[key] = Array.new() if !results.keys.include?(key)
                    results[key][i] = res
                  end
                  i += 1
                end
              else
                i = 0
                value.each { |v|
                  if v.is_a?(Hash)
                    res = NiceHash.validate([v, select_hash_key], values[key][i], only_patterns: only_patterns)
                  else
                    # for the case {cars: ['Ford|Newton|Seat']}
                    res = NiceHash.validate([{key => v}, select_hash_key], {key => values[key][i]}, only_patterns: only_patterns)
                    array_pattern = true
                  end
                  if res.size > 0
                    results[key] = Array.new() if !results.keys.include?(key)
                    results[key][i] = res
                  end
                  i += 1
                }
              end
            end
            unless array_pattern or only_patterns or results.include?(key) or complex_data 
              results[key] = false unless value == values[key]
            end
          else
            unless only_patterns or value.kind_of?(Proc)
              results[key] = false unless value == values[key]
            end
          end

          if same_values.include?(key)
            same_values[key].each { |k|
              if values.keys.include?(k)
                if values[key] != values[k]
                  results[k] = "Not equal to #{key}"
                end
              end
            }
          end
        end
      }
    end

    return results
  end

  ###########################################################################
  # Change only one value at a time and return an Array of Hashes
  # Let's guess we need to test a typical registration REST service and the service has many fields with many validations but we want to test it one field at a time.
  # This method generates values following the patterns on patterns_hash and generates a new hash for every pattern/select field found on patterns_hash using the value supplied on values_hash
  # input:
  #   patterns_hash:
  #     (Hash) Hash where we have defined the patterns to follow.
  #     (Array) In case of array supplied, the pair: [pattern_hash, select_hash_key]. select_hash_key will filter the hash by that key
  #   values_hash: (Hash) Hash of values to use to modify the values generated on patterns_hash
  # output: (Array of Hashes)
  # example:
  #   wrong_min_length_hash = my_hash.generate(:correct, errors: :min_length)
  #   array_of_hashes = NiceHash.change_one_by_one([my_hash, :correct], wrong_min_length_hash)
  #   array_of_hashes.each {|hash_with_one_wrong_field|
  #     #Here your code to send through http the JSON data stored in hash_with_one_wrong_field
  #     #if you want to know which field is the one that is wrong:
  #     res = my_hash.validate(:correct, hash_with_one_wrong_field)
  #   }
  ###########################################################################
  def NiceHash.change_one_by_one(patterns_hash, values_hash)
    if patterns_hash.kind_of?(Array)
      select_key = patterns_hash[1]
      pattern_hash = patterns_hash[0]
    else
      pattern_hash = patterns_hash
      select_key = []
    end
    array = Array.new
    good_values = NiceHash.generate(pattern_hash, select_key)
    select_keys = pattern_hash.pattern_fields(select_key) + pattern_hash.select_fields(select_key)
    select_keys.each { |field|
      new_hash = Marshal.load(Marshal.dump(good_values))
      # to deal with the case same values... like in pwd1, pwd2, pwd3
      if field[-1].kind_of?(Array)
        last_to_set = field[-1]
      else
        last_to_set = [field[-1]]
      end
      last_to_set.each { |f|
        keys = field[0..-2] << f
        new_hash.bury(keys, values_hash.dig(*keys))
      }
      array << new_hash
    }
    return array
  end

  ##################################################
  # Get values from the Hash structure (array of Hashes allowed)
  #   In case the key supplied doesn't exist in the hash then it will be returned nil for that one
  # input:
  #   hashv: a simple hash or a hash containing arrays. Example:
  #    example={"id"=>344,
  #              "customer"=>{
  #                  "name"=>"Peter Smith",
  #                  "phone"=>334334333
  #              },
  #              "tickets"=>[
  #                {"idt"=>345,"name"=>"myFavor1"},
  #                {"idt"=>3123},
  #                {"idt"=>3145,"name"=>"Special ticket"}
  #              ]
  #            }
  #   keys: one key (string) or an array of keys
  # output:
  #   a Hash of Arrays with all values found.
  #       Example of output with example.get_values("id","name")
  #           {"id"=>[334],"name"=>["Peter North"]}
  #       Example of output with example.get_values("idt")
  #           {"idt"=>[345,3123,3145]}
  #
  ####################################################
  def NiceHash.get_values(hashv, keys)
    if keys.kind_of?(String) or keys.kind_of?(Symbol)
      keys = [keys]
    end
    result = Hash.new()
    number_of_results = Hash.new()
    keys.each { |key|
      number_of_results[key] = 0
    }
    if hashv.kind_of?(Array)
      hashv.each { |tmp|
        if tmp.kind_of?(Array) or tmp.kind_of?(Hash)
          n_result = get_values(tmp, keys)
          if n_result != :error
            n_result.each { |n_key, n_value|
              if result.has_key?(n_key)
                if !result[n_key].kind_of?(Array) or
                   (result[n_key].kind_of?(Array) and number_of_results[n_key] < result[n_key].size)
                  if result[n_key].kind_of?(Hash) or result[n_key].kind_of?(Array)
                    res_tx = result[n_key].dup()
                  else
                    res_tx = result[n_key]
                  end
                  result[n_key] = Array.new()
                  result[n_key].push(res_tx)
                  result[n_key].push(n_value)
                else
                  result[n_key].push(n_value)
                end
              else
                result[n_key] = n_value
              end
              number_of_results[n_key] += 1
            }
          end
        end
      }
    elsif hashv.kind_of?(Hash)
      hashv.each { |key, value|
        #if keys.include?(key) then
        #added to be able to access the keys with symbols to strings and opposite
        if keys.include?(key) or keys.include?(key.to_s) or keys.include?(key.to_sym)
          #added to be able to access the keys with symbols to strings and opposite
          key = key.to_s() if keys.include?(key.to_s)
          key = key.to_sym() if keys.include?(key.to_sym)

          if result.has_key?(key)
            if !result[key].kind_of?(Array) or
               (result[key].kind_of?(Array) and number_of_results[key] < result[key].size)
              if result[key].kind_of?(Hash) or result[key].kind_of?(Array)
                res_tx = result[key].dup()
              else
                res_tx = result[key]
              end
              result[key] = Array.new()
              result[key].push(res_tx)
              result[key].push(value)
            else
              result[key].push(value)
            end
          else
            result[key] = value
          end
          number_of_results[key] += 1
        end
        if value.kind_of?(Array) or value.kind_of?(Hash)
          n_result = get_values(value, keys)
          if n_result != :error
            n_result.each { |n_key, n_value|
              if result.has_key?(n_key)
                if !result[n_key].kind_of?(Array) or
                   (result[n_key].kind_of?(Array) and number_of_results[n_key] < result[n_key].size)
                  if result[n_key].kind_of?(Hash) or result[n_key].kind_of?(Array)
                    res_tx = result[n_key].dup()
                  else
                    res_tx = result[n_key]
                  end
                  result[n_key] = Array.new()
                  result[n_key].push(res_tx)
                  result[n_key].push(n_value)
                else
                  result[n_key].push(n_value)
                end
              else
                result[n_key] = n_value
              end
              number_of_results[n_key] += 1
            }
          end
        end
      }
    else
      return :error
    end
    if result.kind_of?(Hash) and caller[0]["get_values"].nil? #no error or anything weird
      (keys - result.keys).each { |k| #in case some keys don't exist in the hash
        result[k] = nil
      }
    end
    return result
  end

  ##################################################
  #  Analyzes the supplied replica and verifies that the structure follows the one supplied on structure
  #
  #  @param structure [Array] [Hash] Contains the structure that should follow the replica. It can be a nested combination of arrays and hashes.
  #  @param replica [Array] [Hash] Contains the element to be verified on following the supplied structure. It can be a nested combination of arrays and hashes.
  #  @param compare_only_if_exist_key [Boolean] (Default false) If true, in case an element exist on structure but doesn't exist on replica won't be verified.
  #
  #  @return [Boolean] true in case replica follows the structure supplied
  #
  #  @example
  #    my_structure = [
  #      {  name: 'xxx',
  #         zip: 'yyyy',
  #         customer: true,
  #         product_ids: [1]
  #      }
  #    ]
  #    my_replica = [ {name: 'Peter Ben', zip: '1121A', customer: false, product_ids: []},
  #                   {name: 'John Woop', zip: '74014', customer: true, product_ids: [10,120,301]}]
  #    NiceHash.compare_structure(my_structure, my_replica)
  #    #>true
  ##################################################
  def NiceHash.compare_structure(structure, replica, compare_only_if_exist_key = false)
    unless structure.class == replica.class or
           ((structure.is_a?(TrueClass) or structure.is_a?(FalseClass)) and (replica.is_a?(TrueClass) or replica.is_a?(FalseClass)))
      puts "NiceHash.compare_structure: different object type #{structure.class} is not #{replica.class}. expected: #{structure.inspect}. found: #{replica.inspect}."
      return false
    end
    if structure.is_a?(Hash)
      structure.each do |key, value|
        if compare_only_if_exist_key and replica.key?(key)
          unless compare_structure(value, replica[key], compare_only_if_exist_key)
            puts "NiceHash.compare_structure: key :#{key} different."
            return false
          end
        elsif compare_only_if_exist_key == false
          unless replica.key?(key)
            puts "NiceHash.compare_structure: key :#{key} different."
            return false 
          end
          unless compare_structure(value, replica[key], compare_only_if_exist_key)
            puts "NiceHash.compare_structure: key :#{key} different."
            return false 
          end
        end
      end
    elsif structure.is_a?(Array)
      # compare all elements of replica with the structure of the first element on structure
      replica.each do |elem|
        unless compare_structure(structure[0], elem, compare_only_if_exist_key)
          return false 
        end
      end
    end
    return true
  end

  ##################################################
  #  Translate a hash of hashes into a string separted by .
  #
  #  @param hash [Hash] The hash we want to translate
  #
  #  @return [String]
  #
  #  @example
  #    my_hash =  { uno: {dos: :tres} }
  #    NiceHash.transtring(my_hash)
  #    #>"uno.dos.tres"
  ##################################################
  def self.transtring(hash)
    keys = []
    if hash.is_a?(Hash)
      hash.each do |k, v|
        if v.is_a?(Hash)
          keys << k
          keys << trans(v)
        else
          keys << k
          keys << v
        end
      end
    else
      keys << hash
    end
    return keys.join(".")
  end

  ##################################################
  #  Deletes the supplied key
  #
  #  @param hash [Hash] The hash we want
  #  @param nested_key [Hash] [String] String with the nested key: 'uno.dos.tres' or a hash { uno: {dos: :tres} }
  #
  #  @return [Hash]
  #
  #  @example
  #  my_hash = { user: {
  #                      address: {
  #                             city: 'Madrid',
  #                             country: 'Spain'
  #                          },
  #                      name: 'Peter',
  #                      age: 33
  #                    },
  #              customer: true
  #  }
  #    NiceHash.delete_nested(my_hash, 'user.address.city')
  #    #>{:user=>{:address=>{:country=>"Spain"}, :name=>"Peter", :age=>33}, :customer=>true}
  ##################################################
  def self.delete_nested(hash, nested_key)
    nested_key = transtring(nested_key)
    keys = nested_key.split(".")
    if keys.size == 1
      hash.delete(nested_key.to_sym)
    else
      last_key = keys[-1]
      eval("hash.#{keys[0..(keys.size - 2)].join(".")}.delete(:#{last_key})")
    end
    return hash
  end

  ##################################################
  #  sets the supplied value on the supplied nested key
  #
  #  @param hash [Hash] The hash we want
  #  @param nested_key [Hash] [String] String with the nested key: 'uno.dos.tres' or a hash { uno: {dos: :tres} }
  #  @param value [] value to set
  #
  #  @return [Hash]
  #
  #  @example
  #  my_hash = { user: {
  #                      address: {
  #                             city: 'Madrid',
  #                             country: 'Spain'
  #                          },
  #                      name: 'Peter',
  #                      age: 33
  #                    },
  #              customer: true
  #  }
  #    NiceHash.set_nested(my_hash, 'user.address.city', 'Barcelona')
  #    #>{:user=>{:address=>{:city=>'Barcelona', :country=>"Spain"}, :name=>"Peter", :age=>33}, :customer=>true}
  ##################################################
  def self.set_nested(hash, nested_key, value, only_if_exist = false)
    nested_key = transtring(nested_key)
    keys = nested_key.split(".")
    if keys.size == 1
      hash[nested_key.to_sym] = value unless only_if_exist and !hash.key?(nested_key.to_sym)
    else
      exist = true
      if only_if_exist
        ht = hash.deep_copy
        keys.each do |k|
          unless ht.key?(k.to_sym)
            exist = false
            break
          end
          ht = ht[k.to_sym]
        end
      end
      if !only_if_exist or (only_if_exist and exist)
        if value.is_a?(String)
          eval("hash.#{nested_key}='#{value}'")
        else
          #todo: consider other kind of objects apart of strings
          eval("hash.#{nested_key}=#{value}")
        end
      end
    end
    return hash
  end
end
