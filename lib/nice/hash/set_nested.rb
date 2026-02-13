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
      parent = hash
      keys[0..-2].each do |k|
        sym = k.to_sym
        return hash unless parent.is_a?(Hash) && parent.key?(sym)
        parent = parent[sym]
      end
      return hash unless parent.is_a?(Hash)
      if only_if_exist
        return hash unless parent.key?(keys[-1].to_sym)
      end
      parent[keys[-1].to_sym] = value
    end
    return hash
  end

end
