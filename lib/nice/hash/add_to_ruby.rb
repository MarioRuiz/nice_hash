class Array

  ###########################################################################
  # Stores a value on the location indicated
  # input:
  #   where: (Array)
  #   value
  # examples:
  #   my_array.bury([3, 0], "doom") # array of array
  #   my_array.bury([2, 1, :original],"the value to set") #array of array of hash
  ###########################################################################
  def bury(where, value)
    me=self
    where[0..-2].each {|key|
      me=me[key]
    }
    me[where[-1]]=value
  end
end


class Hash
  ###########################################################################
  # Returns the value of the key specified in case doesn't exist a Hash method with the same name
  # The keys can be accessed also adding underscore to avoid problems with existent methods
  # Also set values in case = supplied
  # examples:
  #   my_hash.address.correct
  #   my_hash._address._correct
  #   my_hash.city
  #   my_hash._city
  #   my_hash.city="Paris"
  #   my_hash.products[1].price.wrong="AAAAA"
  ###########################################################################
  def method_missing(m, *arguments, &block)
    if m[0]=='_'
      m=m[1..-1].to_sym
    end
    if self.keys.include?(m)
      self[m]
    elsif m.to_s[-1]=="="
      self[m.to_s.chop.to_sym]=arguments[0]
    else
      super
    end
  end

  ###########################################################################
  # Stores a value on the location indicated
  # input:
  #   where: (Array)
  #   value
  # examples:
  #   my_hash.bury([:bip, :doom], "doom") # hash of hash
  #   my_hash.bury([:original, 1, :doom],"the value to set") #hash of array of hash
  ###########################################################################
  def bury(where, value)
    me=self
    where[0..-2].each {|key|
      me=me[key]
    }
    key=where[-1]
    key=[key] unless where[-1].kind_of?(Array) # for the case same value for different keys, for example pwd1, pwd2, pwd3
    key.each {|k|
      me[k]=value
    }
  end

  ###########################################################################
  # It will filter the hash by the key specified on select_hash_key.
  # In case a subhash specified on a value it will be selected only the value of the key specified on select_hash_key
  # More info: NiceHash.select_key
  ###########################################################################
  def select_key(select_hash_key)
    NiceHash.select_key(self, select_hash_key)
  end

  ###########################################################################
  # It will generate a new hash with the values generated from the string patterns and select fields specified.
  # In case supplied select_hash_key and a subhash specified on a value it will be selected only the value of the key specified on select_hash_key
  # If expected_errors specified the values will be generated with the specified errors.
  # More info: NiceHash.generate
  # alias: gen
  ###########################################################################
  def generate(select_hash_key=nil, expected_errors: [], **synonyms)
    NiceHash.generate(self, select_hash_key, expected_errors: expected_errors, **synonyms)
  end

  ###########################################################################
  # Validates a given values_hash_to_validate with string patterns and select fields
  # More info: NiceHash.validate
  # alias: val
  ###########################################################################
  def validate(select_hash_key=nil, values_hash_to_validate)
    NiceHash.validate([self, select_hash_key], values_hash_to_validate, only_patterns: false)
  end

  ###########################################################################
  # Validates a given values_hash_to_validate with string patterns
  # More info: NiceHash.validate
  ###########################################################################
  def validate_patterns(select_hash_key=nil, values_hash_to_validate)
    NiceHash.validate([self, select_hash_key], values_hash_to_validate, only_patterns: true)
  end

  ###########################################################################
  # It will return an array of the keys where we are using string patterns.
  # More info: NiceHash.pattern_fields
  ###########################################################################
  def pattern_fields(*select_hash_key)
    NiceHash.pattern_fields(self, *select_hash_key)
  end

  ###########################################################################
  # It will return an array of the keys where we are using select values of the kind: "value1|value2|value3".
  # More info: NiceHash.select_fields
  ###########################################################################
  def select_fields(*select_hash_key)
    NiceHash.select_fields(self, *select_hash_key)
  end


  alias_method :gen, :generate
  alias_method :val, :validate
  alias_method :patterns, :pattern_fields

end
