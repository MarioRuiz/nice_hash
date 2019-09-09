class NiceHash
   ##################################################
  #  Translate a hash of hashes into a string separted by .
  #
  #  @param hash [Hash] The hash we want to translate
  #
  #  @return [String]
  #
  #  @example
  #    my_hash =  { uno: {dos: :tres} }
  #    NiceHash.transtring(my_hash)
  #    #>"uno.dos.tres"
  ##################################################
  def self.transtring(hash)
    keys = []
    if hash.is_a?(Hash)
      hash.each do |k, v|
        if v.is_a?(Hash)
          keys << k
          keys << transtring(v)
        else
          keys << k
          keys << v
        end
      end
    else
      keys << hash
    end
    return keys.join(".")
  end

end