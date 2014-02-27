Gem::Specification.new do |gem|
  gem.name        = 'mumblr'
  gem.version     = '0.0.0'
  gem.date        = '2014-02-22'
  gem.summary     = "Mongo + Tumblr = Awesome."
  gem.description = "Easily retrieve content from Tumblr and cache it locally with MongoDB."
  gem.authors     = ["Peter Compernolle"]
  gem.email       = 'me@petercompernolle.com'
  gem.homepage    = 'http://petercompernolle.com/mumblr'
  gem.license       = 'MIT'
  #gem.add_dependency "activemodel", "~> 4.0.0"
  gem.add_dependency "tumblr_client"
  gem.add_dependency "bson_ext", "~> 1.5"
  gem.add_dependency "mongo_mapper"#, '>= 0.13.0.beta2'

  gem.files       = ["lib/mumblr.rb"]
end
