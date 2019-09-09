class NiceHash

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
    
end