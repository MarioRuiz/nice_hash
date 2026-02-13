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
    return obj.clone unless obj.is_a?(Array) || obj.is_a?(Hash)
    obj.clone.tap do |new_obj|
      if new_obj.is_a?(Array)
        new_obj.each_with_index do |val, i|
          new_obj[i] = deep_clone(val)
        end
      elsif new_obj.is_a?(Hash)
        new_obj.each do |key, val|
          new_obj[key] = deep_clone(val)
        end
      end
    end
  end
end
