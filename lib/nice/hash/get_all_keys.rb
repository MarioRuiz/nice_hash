class NiceHash
  ##################################################
  #  Get all the keys of a hash
  #
  #  @param hash [Hash] The hash
  #
  #  @return [Array]
  #
  #  @example
  #    my_hash =  { uno: {dos: {tres: 3}} }
  #    NiceHash.get_all_keys(my_hash)
  #    #>[:uno, :dos, :tres]
  ##################################################
  def self.get_all_keys(h)
    h.each_with_object([]) do |(k, v), keys|
      keys << k
      keys.concat(get_all_keys(v)) if v.is_a? Hash
      if v.is_a?(Array)
        v.each do |vv|
          keys.concat(get_all_keys(vv)) if vv.is_a? Hash or vv.is_a? Array
        end
      end
    end
  end
 
end