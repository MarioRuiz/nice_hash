class NiceHash

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
  #   keys: one key (string) or an array of keys. key can be a nested key
  # output:
  #   a Hash of Arrays with all values found.
  #       Example of output with example.get_values("id","name")
  #           {"id"=>344, "name"=>["Peter Smith", ["myFavor1", "Special ticket"]]}
  #       Example of output with example.get_values("idt")
  #           {"idt"=>[345,3123,3145]}
  #       Example of output with example.get_values(:'tickets.idt')
  #           {:"tickets.idt"=>[345,3123,3145]}
  #
  ####################################################
  def NiceHash.get_values(hashv, keys)
    #todo: check if we should return {"id"=>344, "name"=>["Peter Smith", "myFavor1", "Special ticket"]} instead of
    # {"id"=>344, "name"=>["Peter Smith", ["myFavor1", "Special ticket"]]}
    if keys.kind_of?(String) or keys.kind_of?(Symbol)
      keys = [keys]
    end
    if (keys.grep(/\./)).empty?
      nested = false
    else
      nested = true
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
          #todo: check on next ruby versions since it will be not necessary to do it
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
          if nested
            keys_nested = []
            keys.grep(/^#{key}\./).each do |k|
              keys_nested << k.to_s.gsub(/^#{key}\./,'').to_sym
            end
            n_result_tmp = get_values(value, keys_nested)
            n_result = {}
            n_result_tmp.each do |k,v|
              n_result["#{key}.#{k}".to_sym] = v
            end
          else
            n_result = get_values(value, keys)
          end
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
 
end