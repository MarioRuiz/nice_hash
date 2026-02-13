# frozen_string_literal: true

class NiceHash
  ##################################################
  # Flattens a nested hash so keys become dot-notation strings.
  #
  # @param hash [Hash] The hash to flatten
  # @param prefix [String] Internal: current path prefix for recursion
  #
  # @return [Hash] Flat hash with string keys like "user.address.city"
  #
  # @example
  #   NiceHash.flatten_keys({ user: { address: { city: "Madrid" } } })
  #   #=> { "user.address.city" => "Madrid" }
  ##################################################
  def self.flatten_keys(hash, prefix = "")
    return {} unless hash.is_a?(Hash)
    result = {}
    hash.each do |k, v|
      path = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
      if v.is_a?(Hash)
        result.merge!(flatten_keys(v, path))
      else
        result[path] = v
      end
    end
    result
  end

  ##################################################
  # Unflattens a hash with dot-notation keys into a nested hash.
  #
  # @param hash [Hash] Flat hash with string keys like "user.address.city"
  #
  # @return [Hash] Nested hash
  #
  # @example
  #   NiceHash.unflatten_keys({ "user.address.city" => "Madrid" })
  #   #=> { user: { address: { city: "Madrid" } } }
  ##################################################
  def self.unflatten_keys(hash)
    return {} unless hash.is_a?(Hash)
    result = {}
    hash.each do |key_str, value|
      keys = key_str.to_s.split(".")
      keys = keys.map { |k| k.match?(/\A\d+\z/) ? k.to_i : k.to_sym }
      current = result
      keys[0..-2].each do |k|
        current[k] = {} unless current[k].is_a?(Hash)
        current = current[k]
      end
      current[keys[-1]] = value
    end
    result
  end
end
