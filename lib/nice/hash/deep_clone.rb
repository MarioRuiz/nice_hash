class NiceHash
  ##################################################
  #  Deep clones the supplied object
  #
  #  @param obj [Object] The object we want to deep clone
  #
  #  @return [Object]
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
  #    NiceHash.deep_clone(my_hash)
  #    #>{:user=>{:address=>{:city=>"Madrid", :country=>"Spain"}, :name=>"Peter", :age=>33}, :customer=>true}
  ##################################################
  def self.deep_clone(obj)
    obj.clone.tap do |new_obj|
      new_obj.each do |key, val|
        new_obj[key] = deep_clone(val) if val.is_a?(Hash)
      end
    end
  end
end
