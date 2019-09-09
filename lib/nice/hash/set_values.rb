class NiceHash
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
  # Setting specific nested keys
  #   new_hash = my_hash.set_values({'data.lab.products.price': 75, 'data.lab.beep': false})
  ###########################################################################
  def NiceHash.set_values(hash_array, hash_values)
    hashv = Hash.new()
    if hash_array.is_a?(Hash) and hash_array.size > 0
      #for the case same_values on hash_values
      #fex: ({pwd1: 'aaaa', pwd2: 'bbbbb', uno: 1}).set_values({[:pwd1, :pwd2]=>:'1-10:n'})
      # should return : {[:pwd1, :pwd2]=>:'1-10:n', uno: 1}
      #todo: it doesn't work for all cases, just simple one
      if hash_values.is_a?(Hash) and hash_values.keys.flatten.size != hash_values.keys.size
        hash_values.each do |k,v|
          if k.is_a?(Array)
            k.each do |kvk|
              if hash_array.key?(kvk)
                  hash_array[kvk] = hash_values[k]
              end
            end
          end
        end

      end
      hash_array.each do |k, v|
        #for the case of using same_values: [:pwd1, :pwd2] => :'10:N' and supply hash_values: pwd1: 'a', pwd2: 'b'
        #instead of [:pwd1,:pwd2]=>'a'
        same_values_key_done = false
        if k.is_a?(Array) 
          #todo: we are treating here only a simple case, consider to add also nested keys, array of values...
          k.each do |kvk|
            if hash_values.keys.include?(kvk)
              hashv[k] = hash_values[kvk]
              same_values_key_done = true
            end
          end
        end
        unless same_values_key_done
          if hash_values.keys.include?(k)
            hashv[k] = hash_values[k]
          elsif v.is_a?(Array)
            if hash_values.has_rkey?('\.') # the kind of 'uno.dos.tres'
              new_hash_values = {}
              hash_values.each do |kk,vv|
                if kk.to_s.match?(/^#{k}\./)
                  kk = kk.to_s.gsub(/^#{k}\./, '').to_sym
                  new_hash_values[kk] = vv
                end
              end
              hashv[k] = NiceHash.set_values(v, new_hash_values)
            else
              hashv[k] = NiceHash.set_values(v, hash_values)
            end
          elsif v.is_a?(Hash)
            if hash_values.has_rkey?('\.') # the kind of 'uno.dos.tres'
              new_hash_values = {}
              hash_values.each do |kk,vv|
                if kk.to_s.match?(/^#{k}\./)
                  kk = kk.to_s.gsub(/^#{k}\./, '').to_sym
                  new_hash_values[kk] = vv
                end
              end
              hashv[k] = NiceHash.set_values(v, new_hash_values)
            else
              hashv[k] = NiceHash.set_values(v, hash_values)
            end
          else
            hashv[k] = v
          end
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
    
end