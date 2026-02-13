class NiceHash
  ##################################################
  #  Deletes the supplied nested key
  #
  #  @param hash [Hash] The hash we want
  #  @param nested_key [Hash] [String] String with the nested key: 'uno.dos.tres' or a hash { uno: {dos: :tres} }
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
  #    NiceHash.delete_nested(my_hash, 'user.address.city')
  #    #>{:user=>{:address=>{:country=>"Spain"}, :name=>"Peter", :age=>33}, :customer=>true}
  ##################################################
  def self.delete_nested(hash, nested_key)
    nested_key = transtring(nested_key)
    keys = nested_key.split(".")
    if keys.size == 1
      hash.delete(nested_key.to_sym)
    else
      parent = hash
      keys[0..-2].each do |k|
        sym = k.to_sym
        return hash unless parent.is_a?(Hash) && parent.key?(sym)
        parent = parent[sym]
      end
      parent.delete(keys[-1].to_sym) if parent.is_a?(Hash)
    end
    return hash
  end


end
