require 'uri'

module Mumblr
  class << self
    attr_accessor :configuration
  end

  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :mongomapper, :tumblr

    def tumblr=(options)
      unless [:consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret].all? {|s| options.key? s}
        raise ArgumentError, "Tumblr config requires [:consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret]"
      end

      Tumblr.configure do |config|
        config.consumer_key       = options[:consumer_key]
        config.consumer_secret    = options[:consumer_secret]
        config.oauth_token        = options[:oauth_token]
        config.oauth_token_secret = options[:oauth_token_secret]
      end
    end

    def mongomapper=(mongo_url)
      url = URI(mongo_url)
      ::MongoMapper.connection = Mongo::Connection.new(url.host, url.port)
      ::MongoMapper.database = url.path.gsub(/^\//, '')
      ::MongoMapper.database.authenticate(url.user, url.password) if url.user && url.password
    end
  end
end