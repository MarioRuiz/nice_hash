class NiceHash

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
    sp_opts = { expected_errors: expected_errors }.merge(synonyms)

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
            value = NiceHash.generate(value, select_hash_key, expected_errors: expected_errors, **synonyms)
          end
        end
        if value == :uuid
          hashv[key] = expected_errors.empty? ? StringPattern.uuid : (StringPattern.uuid[0..-2] + "X")
        elsif value.kind_of?(String) or value.kind_of?(Symbol)
          if ((StringPattern.optimistic and value.kind_of?(String)) or value.kind_of?(Symbol)) and value.to_s.scan(/^!?\d+-?\d*:.+/).size > 0
            hashv[key] = StringPattern.generate(value, **sp_opts)
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
                v = StringPattern.generate(:"#{v.size}:[#{value.to_s.split("|").join.split(//).uniq.join}]", **sp_opts)
                hashv[key] = v unless value.to_s.split("|").include?(v)
              end
              unless hashv.keys.include?(key)
                # Need a valid 1-char not in the allowed set (do not pass expected_errors)
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
          if value.size == 1
            v = value[0]
            if (v.kind_of?(String) or v.kind_of?(Symbol)) and StringPattern.analyze(v, silent: true).kind_of?(StringPattern::Pattern)
              hashv[key] = []
              (rand(5)+1).times do
                hashv[key]<<StringPattern.generate(v, **sp_opts)
              end
              array_pattern = true
            end
          else
            value.each { |v|
              if (v.kind_of?(String) or v.kind_of?(Symbol)) and StringPattern.analyze(v, silent: true).kind_of?(StringPattern::Pattern)
                hashv[key] = StringPattern.generate(value, **sp_opts)
                array_pattern = true
                break
              end
            }
          end
          unless array_pattern
            value_ret = Array.new
            value.each { |v|
              if v.is_a?(Hash)
                ret = NiceHash.generate(v, select_hash_key, expected_errors: expected_errors, **synonyms)
              else
                ret = NiceHash.generate({ doit: v }, select_hash_key, expected_errors: expected_errors, **synonyms)
                ret = ret[:doit] if ret.is_a?(Hash) and ret.key?(:doit)
              end
              ret = v if ret.kind_of?(Hash) and ret.size == 0
              value_ret << ret
            }
            hashv[key] = value_ret
          end
        elsif value.kind_of?(Range)
          if expected_errors.empty?
            if value.size == Float::INFINITY
              value = (value.min..2**64)
            end
            hashv[key] = rand(value)
          else
            if value.size == Float::INFINITY
              infinite = true
              value = (value.min..2**64)
            else
              infinite = false
              hashv[key] = rand(value)
            end
            expected_errors.each do |er|
              if er == :min_length
                hashv[key] = rand((value.first - value.last)..value.first - 1)
              elsif er == :max_length and !infinite
                hashv[key] = rand((value.last + 1)..(value.last * 2))
              elsif er == :length
                if rand.round == 1 or infinite
                  hashv[key] = rand((value.first - value.last)..value.first - 1)
                else
                  hashv[key] = rand((value.last + 1)..(value.last * 2))
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
                if rand.round == 1
                  hashv[key] = hashv[key].chop
                else
                  hashv[key] = hashv[key] + "Z"
                end
              elsif er == :value
                hashv[key][rand(hashv[key].size - 1)] = "1:L".gen
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
                hashv[key] = "1-10:L".gen
              end
            end
          end
        elsif value.kind_of?(Proc)
          hashv[key] = value.call
        elsif value.kind_of?(Regexp)
          hashv[key] = value.generate(**sp_opts)
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
  # Generates n different hashes from the same pattern (useful for bulk or boundary tests).
  # input:
  #   pattern_hash: (Hash) Hash we want to use to generate the values
  #   n: (Integer) Number of hashes to generate
  #   select_hash_key: (key value) (optional) The key we want to select on the subhashes
  #   expected_errors: (Array) (optional) (alias: errors) Same as in generate
  # output: (Array of Hash)
  # examples:
  #   hashes = NiceHash.generate_n(my_hash, 5, :correct)
  #   hashes = my_hash.generate_n(5, :correct)
  ###########################################################################
  def NiceHash.generate_n(pattern_hash, n, select_hash_key = nil, expected_errors: [], **synonyms)
    n.times.map { NiceHash.generate(pattern_hash, select_hash_key, expected_errors: expected_errors, **synonyms) }
  end
end
