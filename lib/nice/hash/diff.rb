# frozen_string_literal: true

class NiceHash
  ##################################################
  # Compares two hashes and returns differences with dot-notation paths.
  #
  # @param expected [Hash, Array] Expected structure (hash or array of hashes)
  # @param actual [Hash, Array] Actual structure to compare
  # @param prefix [String] Internal: current path prefix for recursion
  #
  # @return [Hash] Path => { expected: value, got: value } for each difference
  #
  # @example
  #   expected = { user: { address: { city: "Madrid" } } }
  #   actual   = { user: { address: { city: "London" } } }
  #   NiceHash.diff(expected, actual)
  #   #=> { "user.address.city" => { expected: "Madrid", got: "London" } }
  ##################################################
  def self.diff(expected, actual, prefix = "")
    result = {}
    exp_keys = expected.is_a?(Hash) ? expected.keys : (expected.is_a?(Array) ? (0...expected.size) : nil)
    act_keys = actual.is_a?(Hash) ? actual.keys : (actual.is_a?(Array) ? (0...actual.size) : nil)

    if expected.is_a?(Hash) && actual.is_a?(Hash)
      all_keys = (expected.keys + actual.keys).uniq
      all_keys.each do |k|
        path = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
        exp_v = expected[k]
        act_v = actual[k]
        if !expected.key?(k)
          result[path] = { expected: nil, got: act_v }
        elsif !actual.key?(k)
          result[path] = { expected: exp_v, got: nil }
        elsif exp_v.is_a?(Hash) && act_v.is_a?(Hash)
          result.merge!(diff(exp_v, act_v, path))
        elsif exp_v.is_a?(Array) && act_v.is_a?(Array)
          max_len = [exp_v.size, act_v.size].max
          max_len.times do |i|
            result.merge!(diff(exp_v[i], act_v[i], "#{path}[#{i}]"))
          end
        elsif exp_v != act_v
          result[path] = { expected: exp_v, got: act_v }
        end
      end
    elsif expected.is_a?(Array) && actual.is_a?(Array)
      max_len = [expected.size, actual.size].max
      max_len.times do |i|
        result.merge!(diff(expected[i], actual[i], prefix.empty? ? "[#{i}]" : "#{prefix}[#{i}]"))
      end
    elsif expected != actual
      result[prefix] = { expected: expected, got: actual } unless prefix.empty?
    end
    result
  end
end
