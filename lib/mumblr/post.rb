module Mumblr
  class Post
    include MongoMapper::Document

    key :tumblr_id, Integer
    key :blog_name, String
    key :post_url, String
    key :type, String, default: nil
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
