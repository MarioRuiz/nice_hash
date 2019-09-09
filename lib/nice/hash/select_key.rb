class NiceHash
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

end