require 'test/unit'
require 'mumblr'

class MumblrTest < Test::Unit::TestCase
  def setup
    Mumblr.configure do |config|
      config.mongomapper  = 'mongomapper://localhost:27017/test'
      config.tumblr       = {
        consumer_key: "YOUR_CONSUMER_KEY",
        consumer_secret: "YOUR_CONSUMER_SECRET",
        oauth_token: "YOUR_OAUTH_TOKEN",
        oauth_token_secret: "YOUR_OATH_TOKEN_SECRET"
      }
      config.default_blog = 'thelowlypeon'
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

  def test_blogname
    Mumblr.blog = 'thelowlypeon'
    assert_not_nil Mumblr.blog
    assert_equal Mumblr.blog, 'thelowlypeon'
  end

  def test_tumblr_client
    assert_not_nil Mumblr.tumblr_client
    assert Mumblr.tumblr_client.is_a?(Tumblr::Client)
  end

  def test_get_response_from_tumblr
    assert_nothing_raised do
      Mumblr.tumblr_client.posts(Mumblr.blog, {limit: 1})
    end
    response = Mumblr.tumblr_client.posts(Mumblr.blog, {limit: 1})
    assert_not_nil response
    assert response.has_key?('posts')
  end

  def test_fetch_from_tumblr_with_options
    assert_nothing_raised do 
      Mumblr::Post.fetch_from_tumblr({limit: 1})
    end
    assert_not_nil Mumblr::Post.fetch_from_tumblr({limit: 1})
  end

  def test_change_blogname
    blogname = 'outofpages'
    Mumblr.blog = blogname
    response = Mumblr::Post.fetch_from_tumblr({limit: 1})
    assert response.present?
    assert_equal response.first['blog_name'], blogname
  end

  def test_filter_tumblr_response
    response = Mumblr.request_from_tumblr({id: 1}) #post 1 exists by a guy named david
    filtered = Mumblr::Post.filter_tumblr_response(response, filter_by_blog: true, return_single: true)
    assert filtered.nil?, "Tumblr post #1 not filtered"

    unfiltered = Mumblr::Post.filter_tumblr_response(response, filter_by_blog: false, return_single: true)
    assert_not_nil unfiltered, "Post from other user was filtered"
  end
end
