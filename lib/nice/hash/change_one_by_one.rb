class NiceHash
  ###########################################################################
  # Change only one value at a time and return an Array of Hashes
  # Let's guess we need to test a typical registration REST service and the service has many fields with many validations but we want to test it one field at a time.
  # This method generates values following the patterns on patterns_hash and generates a new hash for every pattern/select field found on patterns_hash using the value supplied on values_hash
  # input:
  #   patterns_hash:
  #     (Hash) Hash where we have defined the patterns to follow.
  #     (Array) In case of array supplied, the pair: [pattern_hash, select_hash_key]. select_hash_key will filter the hash by that key
  #   values_hash: (Hash) Hash of values to use to modify the values generated on patterns_hash
  # output: (Array of Hashes)
  # example:
  #   wrong_min_length_hash = my_hash.generate(:correct, errors: :min_length)
  #   array_of_hashes = NiceHash.change_one_by_one([my_hash, :correct], wrong_min_length_hash)
  #   array_of_hashes.each {|hash_with_one_wrong_field|
  #     #Here your code to send through http the JSON data stored in hash_with_one_wrong_field
  #     #if you want to know which field is the one that is wrong:
  #     res = my_hash.validate(:correct, hash_with_one_wrong_field)
  #   }
  ###########################################################################
  def NiceHash.change_one_by_one(patterns_hash, values_hash)
    if patterns_hash.kind_of?(Array)
      select_key = patterns_hash[1]
      pattern_hash = patterns_hash[0]
    else
      pattern_hash = patterns_hash
      select_key = []
    end
    array = Array.new
    good_values = NiceHash.generate(pattern_hash, select_key)
    select_keys = pattern_hash.pattern_fields(select_key) + pattern_hash.select_fields(select_key)
    select_keys.each { |field|
      new_hash = Marshal.load(Marshal.dump(good_values))
      # to deal with the case same values... like in pwd1, pwd2, pwd3
      if field[-1].kind_of?(Array)
        last_to_set = field[-1]
      else
        last_to_set = [field[-1]]
      end
      last_to_set.each { |f|
        keys = field[0..-2] << f
        new_hash.bury(keys, values_hash.dig(*keys))
      }
      array << new_hash
    }
    return array
  end
 
end