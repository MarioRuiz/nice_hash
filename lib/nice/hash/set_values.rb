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
      hash_array.each do |k, v|
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