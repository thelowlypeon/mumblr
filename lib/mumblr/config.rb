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
    attr_accessor :mongomapper, :tumblr, :default_blog, :include_private

    def initialize(*args)
      self.mongomapper = ENV['MONGOMAPPER_CONFIG'] #default mongo config
      super
    end

    def tumblr=(options)
      Tumblr.configure do |config|
        config.consumer_key       = options[:consumer_key]       || ENV['TUMBLR_CONSUMER_KEY']
        config.consumer_secret    = options[:consumer_secret]    || ENV['TUMBLR_CONSUMER_SECRET']
        config.oauth_token        = options[:oauth_token]        || ENV['TUMBLR_OAUTH_TOKEN']
        config.oauth_token_secret = options[:oauth_token_secret] || ENV['TUMBLR_OAUTH_TOKEN_SECRET']
      end

      @tumblr = Tumblr::Client.new
    end

    def tumblr
      if @tumblr.nil?
        self.tumblr = {}
      end
      raise RuntimeError, "Tumblr client not present. Please initialize Tumblr configs." if @tumblr.nil?
      @tumblr
    end

    def mongomapper=(mongo_url)
      url = URI(mongo_url)
      ::MongoMapper.connection = Mongo::Connection.new(url.host, url.port)
      ::MongoMapper.database = url.path.gsub(/^\//, '')
      ::MongoMapper.database.authenticate(url.user, url.password) if url.user && url.password
    end

    def default_blog=(blog)
      @default_blog = blog
    end

    def default_blog
      @default_blog || ENV['MUMBLR_DEFAULT_BLOG']
    end

    def include_private=(include_private)
      @include_private = include_private
    end

    def include_private
      @include_private ||= false
    end
  end
end
