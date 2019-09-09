class NiceHash
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