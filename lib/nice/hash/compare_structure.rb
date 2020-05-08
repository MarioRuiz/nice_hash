class NiceHash
  ##################################################
  #  Analyzes the supplied replica and verifies that the structure follows the one supplied on structure
  #
  #  @param structure [Array] [Hash] Contains the structure that should follow the replica. It can be a nested combination of arrays and hashes.
  #  @param replica [Array] [Hash] Contains the element to be verified on following the supplied structure. It can be a nested combination of arrays and hashes.
  #  @param compare_only_if_exist_key [Boolean] (Default false) If true, in case an element exist on structure but doesn't exist on replica won't be verified.
  #  @param patterns [Hash] add verification of data values following the patterns supplied on a one level hash
  #
  #  @return [Boolean] true in case replica follows the structure supplied
  #
  #  @example
  #    my_structure = [
  #      {  name: 'xxx',
  #         zip: 'yyyy',
  #         customer: true,
  #         product_ids: [1]
  #      }
  #    ]
  #    my_replica = [ {name: 'Peter Ben', zip: '1121A', customer: false, product_ids: []},
  #                   {name: 'John Woop', zip: '74014', customer: true, product_ids: [10,120,301]}]
  #    NiceHash.compare_structure(my_structure, my_replica)
  #    #>true
  ##################################################
  def NiceHash.compare_structure(structure, replica, compare_only_if_exist_key = false, patterns = {})
    unless structure.class == replica.class or
            ((structure.is_a?(TrueClass) or structure.is_a?(FalseClass)) and (replica.is_a?(TrueClass) or replica.is_a?(FalseClass)))
      puts "NiceHash.compare_structure: different object type #{structure.class} is not #{replica.class}. expected: #{structure.inspect}. found: #{replica.inspect}."
      return false
    end
    success = true
    if structure.is_a?(Hash)
      structure.each do |key, value|
        if patterns.key?(key) and replica.key?(key)
          unless (patterns[key].is_a?(Array) and replica[key].is_a?(Array) and replica[key].empty?) or 
            (compare_only_if_exist_key and replica.key?(key) and replica[key].nil?) or 
            {key => patterns[key]}.validate({key => replica[key]}).empty?
            puts "NiceHash.compare_structure: key :#{key} not following pattern #{patterns[key]}. value: #{replica[key]}"
            success = false
          end
        end

        if compare_only_if_exist_key and replica.key?(key) and !replica[key].nil?
          unless compare_structure(value, replica[key], compare_only_if_exist_key, patterns)
            puts "NiceHash.compare_structure: key :#{key} different."
            success = false
          end
        elsif compare_only_if_exist_key == false
          unless replica.key?(key)
            puts "NiceHash.compare_structure: key :#{key} missing."
            success = false
          else
            unless compare_structure(value, replica[key], compare_only_if_exist_key, patterns)
              puts "NiceHash.compare_structure: key :#{key} different."
              success = false
            end
          end
        end
      end
    elsif structure.is_a?(Array)
      # compare all elements of replica with the structure of the first element on structure
      replica.each do |elem|
        unless compare_structure(structure[0], elem, compare_only_if_exist_key, patterns)
          success = false
        end
      end
    end
    return success
  end 
end