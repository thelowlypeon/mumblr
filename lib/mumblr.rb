require 'tumblr_client'
require 'mongo_mapper'
require 'mumblr/config'
require 'mumblr/post'

module Mumblr
  class << self
    attr_accessor :blog

    def self.blog
      @blog ||= @configuration.default_blog
    end
  end

  def self.tumblr_client
    @configuration.tumblr || Tumblr::Client.new
  end

  def self.request_from_tumblr(options)
    Mumblr.tumblr_client.posts(self.blog, options)
  end
end
