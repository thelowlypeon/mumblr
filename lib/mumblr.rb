require 'tumblr_client'
require 'mongo_mapper'
require 'mumblr/config'
require 'mumblr/post'
Dir[File.dirname(__FILE__) + '/mumblr/models/*.rb'].each {|file| require file }

module Mumblr
  class << self
    @blog

    def blog
      @blog ||= @configuration.default_blog
    end

    def blog=(name)
      @blog = name
    end
  end

  def self.tumblr_client
    @configuration.tumblr || Tumblr::Client.new
  end

  def self.request_from_tumblr(options)
    Mumblr.tumblr_client.posts(self.blog, options)
  end
end
