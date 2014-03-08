require 'test/unit'
require 'mumblr'

class MumblrTest < Test::Unit::TestCase
  def setup
    Mumblr.configure do |config|
      config.mongomapper = 'mongomapper://localhost:27017/test'
      config.tumblr      = {
        consumer_key: "YOUR_CONSUMER_KEY",
        consumer_secret: "YOUR_CONSUMER_SECRET",
        oauth_token: "YOUR_OAUTH_TOKEN",
        oauth_token_secret: "YOUR_OATH_TOKEN_SECRET"
      }
    end
  end

  def teardown
    Mumblr::Post.delete_all
  end

  def test_database_config
    assert_equal 'test', MongoMapper.database.name
  end
  
  def test_classes_defined
    assert defined?(Mumblr::Post), "Post not defined"
    assert defined?(Mumblr::TextPost), "TextPost not defined"
    assert Mumblr::TextPost < Mumblr::Post, "TextPost does not extend Post"
  end

  def test_construct_post
    assert_nothing_raised do
      post = Mumblr::Post.new(id: 1234, type: "text")
    end
  end

  def test_initializer
    post = Mumblr::Post.new(id: 1234, type: "text")
    assert_not_nil post.id
  end 

  def test_accessor_attribute_method
    @url = "http://thelowlypeon.tumblr.com/post/1234/slug"
    post = Mumblr::Post.new(id: 1234, type: "text")
    post.post_url = @url
    assert_not_nil post.post_url
    assert_equal post.post_url, @url
  end

  def test_mongo_save
    assert_nothing_raised do 
      post = Mumblr::Post.new(id: 1234)
      post.save
    end
    found = Mumblr::Post.find(1234)
    assert_not_nil found
    assert_equal found.id, 1234
  end
end
