require "nice_hash"

RSpec.describe NiceHash, "#change_one_by_one" do
  it "changes the hash one by one " do
    wrong_min_length_hash = @hash.generate(:correct, errors: :min_length)
    array_of_hashes = NiceHash.change_one_by_one([@hash, :correct], wrong_min_length_hash)
    expect(array_of_hashes.size).to eq 6
    array_of_hashes.each { |hash_with_one_wrong_field|
      res = @hash.validate(:correct, hash_with_one_wrong_field)
      #only one wrong
      expect(res.size).to eq 1
    }
  end
end
