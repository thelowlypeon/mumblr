module Mumblr
  class Post
    include MongoMapper::Document

    key :tumblr_id, Integer
    key :blog_name, String
    key :post_url, String
    key :type, String, default: nil
    key :timestamp, Integer
    key :date, Date
    key :format, String
    key :reblog_key, String
    key :tags, Array
    key :note_count, Integer
    key :bookmarklet, Boolean, default: false
    key :mobile, Boolean, default: false
    key :source_url, String
    key :source_title, String
    key :liked, Boolean, default: nil
    key :state, String
    key :total_posts, Integer
    timestamps!

    def self.new(args)
      if args.is_a?(Hash)
        id = args[:tumblr_id] || args['tumblr_id'] || args[:id] || args['id'] || nil
        blog_name = args[:blog_name] || args['blog_name'] || Mumblr.blog
        args = args.except(:id, 'id', :blog_name, 'blog_name')
        args[:tumblr_id] = id
        args[:blog_name] = blog_name
        unless id.nil?
          exists = self.where(tumblr_id: id).first
          unless exists.nil?
            args.each do |k,v|
              exists.send("#{k}=", v)
            end
            return exists
          end
        end
      end
      super args
    end

    #retrieve post from mongo, fetch from tumblr if not found
    def self.find(tumblr_id, fetch_if_not_found = true)
      options = {tumblr_id: tumblr_id}
      options[:type] = @type unless @type.blank?
      options[:blog_name] = Mumblr.blog unless Mumblr.blog.blank?
      post = self.where(options).first
      post.nil? && fetch_if_not_found ? self.find!(tumblr_id) : post
    end

    # fetch from tumblr. insert, or update if exists
    def self.find!(tumblr_id)
      posts = self.all!({limit: 1, id: tumblr_id})
      unless posts.nil?
        post = posts.first
        post.save
        post
      else
        nil
      end
    end

    # ALERT: when querying mongo, this should be "tags". tumblr is "tag"
    def self.tagged(tag, fetch_if_not_found = true)
      options = {tags: tag}
      options[:type] = @type unless @type.blank?
      options[:blog_name] = Mumblr.blog unless Mumblr.blog.blank?
      posts = self.where(options)
      posts.empty? && fetch_if_not_found ? self.tagged!(tag) : posts
    end

    # ALERT: when querying tumblr, this should be "tag". mongo is "tags"
    # Note: Heed caution when assuming this returns something. Tumblr's API
    #       will NOT return private posts when retrieved by tag, but WILL
    #       when retrieved using .all
    def self.tagged!(tag, options={})
      self.all!(options.merge({tag: tag}))
    end

    # fetch from tumblr and cache in mongo
    def self.all!(options={})
      options[:type] = @type unless @type.blank?
      hash = self.fetch_from_tumblr(options)
      return nil if hash.blank?
      posts = []
      hash.each do |post_hash|
        post = self.class_from_type(@type.present? ? @type : post_hash['type']).new(post_hash)
        post.save
        posts << post
      end
      posts
    end

    def self.all(options={})
      self.where(blog_name: Mumblr.blog) unless Mumblr.blog.empty?
      super options
    end

    # return a single post chosen randomly
    def self.random(options={})
      options[:type] = @type unless @type.blank?
      options[:blog_name] = Mumblr.blog unless Mumblr.blog.blank?
      collection = self.where(options)
      collection.first(limit: 1, offset: rand(collection.count))
    end

    private

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
        if options.is_a?(Integer)
          options = {id: options, limit: 1}
          options[:return_single] = true
        end
        options = {filter_by_blog: true}.merge(options)
        options[:type] = @type if @type.present?
        response = Mumblr.request_from_tumblr(options)
        self.filter_tumblr_response response, options
      end

      def self.filter_tumblr_response(response, options={})
        #puts response.to_json
        unless response.nil? || !response.has_key?('posts')
          options = {fliter_by_blog: true, return_single: false}.merge(options)
          posts = []
          response['posts'].each do |post|
            if (!options[:filter_by_blog] || post['blog_name'] == Mumblr.blog) && (Mumblr.configuration.include_private || post['state'] != 'private')
              posts << post unless options[:filter_by_blog] && post['blog_name'] != Mumblr.blog
            end
          end
          return options[:return_single] && posts.present? ? posts.first : posts
        end
        raise Exception, "Invalid response from Tumblr: " + response.to_json
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
