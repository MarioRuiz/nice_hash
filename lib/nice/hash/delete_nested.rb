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
      last_key = keys[-1]
      eval("hash.#{keys[0..(keys.size - 2)].join(".")}.delete(:#{last_key})")
    end
    return hash
  end

 
end