module Mumblr
  class Post
    include MongoMapper::Document

    key :tumblr_id, Integer
    key :blog_name, String
    key :post_url, String
    key :type, String, default: nil

    def initialize(options)
      if options.has_key?('id')
        options['tumblr_id'] = options['id']
        options.delete('id')
      end
      super
    end

    def self.find(tumblr_id)
      options = {tumblr_id: tumblr_id}
      options['type'] = @type unless @type.blank?
      self.where(tumblr_id: tumblr_id).first
    end

    def self.random(options={})
      options['type'] = @type unless @type.blank?
      collection = self.where(options)
      collection.first(limit: 1, offset: rand(collection.count))
    end

    def self.find!(tumblr_id)
      post = self.find(tumblr_id)
      if post.nil?
        hash = self.fetch_from_tumblr(tumblr_id)
        return nil if hash.blank?
        post = self.class_from_type(@type.present? ? @type : hash['type']).new(hash)
        post.save
      end
      post
    end

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
        options = {id: options, limit: 1}
        options['type'] = @type if @type.present?
        return_single = true
      end
      options['type'] = @type unless @type.blank?
      response = Mumblr.request_from_tumblr(options)
      self.filter_tumblr_response response, {filter_by_blog: true, return_single: return_single}
    end

    def self.filter_tumblr_response(response, options={})
      unless response.nil? || response['posts'].blank?
        filter_by_blog = options.has_key?(:filter_by_blog) ? options[:filter_by_blog] : true
        return_single  = options.has_key?(:return_single) ? options[:return_single] : false

        posts = []
        response['posts'].each do |post|
          posts << post unless filter_by_blog && post['blog_name'] != response['blog']['name']
        end
        return return_single ? posts.first : posts
      end
      raise Exception, "Invalid response from Tumblr"
    end

    # For a given Tumblr post "type", return the class of the 
    #  appropriate child of Post.
    #
    # new_object = Post.instance_from_type("link") # => LinkPost
    # new_object = Post.instance_from_type("photo") # => PhotosetPost
    def self.class_from_type(type)
      if ['text', 'link', 'quote', 'chat', 'video'].include?(type)
        classname = type.camelize + 'Post'
      elsif type == 'photo'
        classname = 'PhotosetPost'
      else
        raise ArgumentError, "Tying to construct a Tumblr post from unsupported type '#{type}'"
      end
      Mumblr.const_get(classname)
    end
  end
end
