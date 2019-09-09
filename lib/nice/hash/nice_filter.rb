class NiceHash
 
  ##################################################
  #  Filter the hash supplied and returns only the specified keys
  #
  #  @param hash [Hash] The hash we want to filter
  #  @param keys [Array] [Symbol] Array of symbols or symbol. Nested keys can be used: 'uno.dos.tres'
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
  #                      age: 33,
  #                      customers: [{name: 'Peter', currency: 'Euro'}, {name:'John', currency: 'Euro'}]
  #                    },
  #              customer: true
  #  }
  #    NiceHash.nice_filter(my_hash, [:'user.address.city', :'customer', :'user.customers.name'])
  #    #> {:user => {:address => {:city => "Madrid"}, :customers => [{:name => "Peter"}, {:name => "John"}]}, :customer => true}
  ##################################################
  def self.nice_filter(hash, keys)
    result = {}
    keys = [keys] unless keys.is_a?(Array)
    keys.each do |k|
      kn = k.to_s.split('.')
      if hash.is_a?(Hash) and hash.key?(k)
          if hash[k].is_a?(Hash)
              result[k] = {} unless result.key?(k)
          else
              result[k] = hash[k]
          end
      elsif hash.is_a?(Hash) and hash.key?(kn.first.to_sym)
          keys_nested = []
          keys.grep(/^#{kn.first}\./).each do |k2|
            keys_nested << k2.to_s.gsub(/^#{kn.first}\./,'').to_sym
          end
          result[kn.first.to_sym] = nice_filter(hash[kn.first.to_sym], keys_nested)
      elsif hash.is_a?(Array)
          result = []
          hash.each do |a|
              res = nice_filter(a, keys)
              result << res unless res.empty?
          end
      end
    end
    return result
  end
end