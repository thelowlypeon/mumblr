module Mumblr
  class Post
    include MongoMapper::Document

    key :tumblr_id, Integer
    key :blog_name, String
    key :post_url, String
    key :type, String, default: nil

    # Fetch raw JSON data from tumblr. If parameter is
    #   an integer, returns a single hash, else returns
    #   an array of all records returned from Tumblr.
    #   Options can be any accepted by tumblr_client gem.
    #
    #   If no response from Tumblr, Exception is raised
    #
    #   Post.fetch_from_tumblr(limit: 10, type: "text") # => [{id: 12345, title: "Here is the title", ...}, {id: 12346, ...}]
    #   Post.fetch_from_tumblr(12345) # => {id: 12345, title: "Here is the title", ...}
    def self.fetch_from_tumblr(options={limit: 20})
      return_single = false
      if options.is_a?(Integer)
        options = {:id => options}
        options['type'] = @type if @type.present?
        return_single = true
      end
      options['type'] = @type unless @type.blank?
      response = Mumblr.request_from_tumblr(options)
      self.filter_tumblr_response(response, filter_by_blog: true, return_single: return_single)
    end

    def self.filter_tumblr_response(response, options={})
      unless response.nil? || response['posts'].blank?
        filter_by_blog = options.has_key?(:filter_by_blog) ? options[:filter_by_blog] : true
        return_single  = options.has_key?(:return_single) ? options[:return_single] : false

        posts = []
        response['posts'].each do |post|
          posts << post if !filter_by_blog || post['blog_name'] == response['blog']['name']
        end
        return return_single ? posts.first : posts
      end
      raise Exception, "Invalid response from Tumblr"
    end

  end

  class TextPost < Post
    key :type, String, default: 'text'
    key :title, String
  end

  class LinkPost < Post
    key :type, String, default: 'link'
    key :url, String
  end
end
