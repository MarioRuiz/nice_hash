class NiceHash

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
    
end