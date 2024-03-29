Gem::Specification.new do |s|
  s.name        = 'nice_hash'
  s.version     = '1.18.7'
  s.summary     = "NiceHash creates hashes following certain patterns so your testing will be much easier. Parse and filter JSON. Perfect to be used in test data factories"
  s.description = "NiceHash creates hashes following certain patterns so your testing will be much easier. Parse and filter JSON. You can easily generate all the hashes you want following the criteria you specify. Many other features coming to Hash class like the methods 'bury' or select_key, access the keys like methods: my_hash.my_key.other_key. You will be able to generate thousands of different hashes just declaring one and test easily APIs based on JSON for example. Perfect to be used in test data factories"
  s.authors     = ["Mario Ruiz"]
  s.email       = 'marioruizs@gmail.com'
  s.files       = ["lib/nice_hash.rb",Dir["lib/nice/hash/*.rb"],"LICENSE","README.md",".yardopts"]
  s.extra_rdoc_files = ["LICENSE","README.md"]
  s.homepage    = 'https://github.com/MarioRuiz/nice_hash'
  s.license       = 'MIT'
  s.post_install_message = "Thanks for installing! Visit us on https://github.com/MarioRuiz/nice_hash"
  s.add_runtime_dependency 'string_pattern', '~> 2.3', '>= 2.3.0'
  s.add_development_dependency 'rspec', '~> 3.9', '>= 3.9.0'
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
end
