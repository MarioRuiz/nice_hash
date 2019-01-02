class String
  
  ###########################################################################
  # When comparing an string and an integer, float or nil, it will be automatically converted to string:
  #   "300" == 300 #will return true
  #   200.1=="200.1" #will return true
  #   ""==nil #will return true
  ###########################################################################
  def ==(par)
    if par.kind_of?(Integer) or par.nil? or par.kind_of?(Float) then
      super(par.to_s())
    else
      super(par)
    end
  end

  ###########################################################################
  #  In case the string is a json it will return the keys specified. the keys need to be provided as symbols
  #  input:
  #    keys:
  #       1 value with key or an array of keys
  #         In case the key supplied doesn't exist in the hash then it will be returned nil for that one
  #  output:
  #    if keys given: a hash of (keys, values) or the value, if the key is found more than once in the json string, then it will be return a hash op arrays
  #    if no keys given, an empty hash
  ###########################################################################
  def json(*keys)
    require 'json'
    feed_symbols = JSON.parse(self, symbolize_names: true)
    result = {}
    if !keys.empty?
      result_tmp = if keys[0].is_a?(Symbol)
                     NiceHash.get_values(feed_symbols, keys)
                   else
                     {}
                   end

      if result_tmp.size == 1
        result = if result_tmp.values.is_a?(Array) && (result_tmp.values.size == 1)
                   result_tmp.values[0]
                 else
                   result_tmp.values
                 end
      else
        result_tmp.each do |key, value|
          result[key] = if (value.is_a?(Array) || value.is_a?(Hash)) && (value.size == 1)
                          value[0]
                        else
                          value
                        end
        end
      end

    else
      result = feed_symbols
    end
    result
  end
end

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
    me = self
    where[0..-2].each do |key|
      me = me[key]
    end
    me[where[-1]] = value
  end

  ###########################################################################
  #  In case of an array of json strings will return the keys specified. The keys need to be provided as symbols
  #  input:
  #    keys:
  #       1 value with key or an array of keys
  #         In case the key supplied doesn't exist in the hash then it will be return nil for that one
  #  output:
  #    if keys given: a hash of (keys, values) or the value, if the key is found more than once in the json string, then it will be return a hash of arrays
  #    if no keys given, an empty hash
  ###########################################################################
  def json(*keys)
    json_string = "[#{join(',')}]"
    json_string.json(*keys)
  end
end

require 'date'
class Date
  ###########################################################################
  # It will generate a random date
  # In case days is a Date it will generate until that date
  # In case days is an Integer it will generate from the self date + the number of days specified
  # examples:
  #   puts Date.today.random(60) # random date from today to 60 days after
  #   puts Date.strptime('01-09-2005', '%d-%m-%Y').random(100)
  #   puts Date.new(2003,10,31).random(Date.today) #Random date from 2003/10/31 to today
  ###########################################################################
  def random(days)
    if days.kind_of?(Date) then
      dif_dates = self - (days+1)
      date_result = self + rand(dif_dates)
      return date_result
    elsif days.kind_of?(Integer) then
      date_result = self + rand(days+1)
      return date_result
    end
  end

end


class Time
  # It will return in the format: '%Y-%m-%dT%H:%M:%S.000Z'
  # Example: puts Time.now.stamp
  def stamp
    return self.strftime('%Y-%m-%dT%H:%M:%S.000Z')
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
    m = m[1..-1].to_sym if m[0] == '_'
    if key?(m)
      self[m]
    elsif m.to_s[-1] == '='
      self[m.to_s.chop.to_sym] = arguments[0]
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
    me = self
    where[0..-2].each do |key|
      me = me[key]
    end
    key = where[-1]
    key = [key] unless where[-1].is_a?(Array) # for the case same value for different keys, for example pwd1, pwd2, pwd3
    key.each do |k|
      me[k] = value
    end
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
  def generate(select_hash_key = nil, expected_errors: [], **synonyms)
    NiceHash.generate(self, select_hash_key, expected_errors: expected_errors, **synonyms)
  end

  ###########################################################################
  # Validates a given values_hash_to_validate with string patterns and select fields
  # More info: NiceHash.validate
  # alias: val
  ###########################################################################
  def validate(select_hash_key = nil, values_hash_to_validate)
    NiceHash.validate([self, select_hash_key], values_hash_to_validate, only_patterns: false)
  end

  ###########################################################################
  # Validates a given values_hash_to_validate with string patterns
  # More info: NiceHash.validate
  ###########################################################################
  def validate_patterns(select_hash_key = nil, values_hash_to_validate)
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

  ###########################################################################
  # Get values of the keys supplied from the Hash structure.
  # More info: NiceHash.get_values
  ###########################################################################
  def get_values(*keys)
    NiceHash.get_values(self, keys)
  end

  alias gen generate
  alias val validate
  alias patterns pattern_fields
end
