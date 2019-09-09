class NiceHash

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
    if pattern_hash.keys.size == get_all_keys(pattern_hash).size and values.keys.size != get_all_keys(values) and
      pattern_hash.keys.size == pattern_hash.keys.flatten.size # dont't set_values for the case of same_value 
      # all patterns on patterns_hash are described on first level, so no same structure than values
      pattern_hash = values.set_values(pattern_hash)
    end
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
            if values[key].is_a?(String) and values[key].size == 24
              d = Date.strptime(values[key], "%Y-%m-%dT%H:%M:%S.%LZ") rescue results[key] = false
            elsif values[key].is_a?(Time) or values[key].is_a?(Date) or values[key].is_a?(DateTime)
              # correct
            else
              results[key] = false
            end
          elsif value.kind_of?(Module) and value == Boolean
            results[key] = false unless values[key].is_a?(Boolean)
          elsif value.kind_of?(Regexp)
            rex = Regexp.new("^#{value}$")
            unless values[key].to_s.match?(rex)
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
                i = 0
                if values[key].class == value.class
                  values[key].each do |v|
                    if value[0].is_a?(Hash)
                      res = NiceHash.validate([value[0], select_hash_key], v, only_patterns: only_patterns)
                    else
                      # for the case {cars: ['Ford|Newton|Seat']}
                      res = NiceHash.validate([{ key => value[0] }, select_hash_key], { key => v }, only_patterns: only_patterns)
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
                  results[key] = false
                end
              else
                i = 0
                value.each { |v|
                  if v.is_a?(Hash)
                    res = NiceHash.validate([v, select_hash_key], values[key][i], only_patterns: only_patterns)
                  else
                    # for the case {cars: ['Ford|Newton|Seat']}
                    res = NiceHash.validate([{ key => v }, select_hash_key], { key => values[key][i] }, only_patterns: only_patterns)
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

    
end