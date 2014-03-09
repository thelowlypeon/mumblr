require 'test/unit'
require 'mumblr'

class MumblrTest < Test::Unit::TestCase
  @@default_blog = 'thelowlypeon'
  def setup
    Mumblr.configure do |config|
      config.mongomapper  = 'mongomapper://localhost:27017/test'
      config.tumblr       = {
        consumer_key: "YOUR_CONSUMER_KEY",
        consumer_secret: "YOUR_CONSUMER_SECRET",
        oauth_token: "YOUR_OAUTH_TOKEN",
        oauth_token_secret: "YOUR_OATH_TOKEN_SECRET"
      }
      config.default_blog = @@default_blog
    end
  end

  def teardown
    Mumblr::Post.delete_all
  end

  def test_saved_textpost_found_by_generic_search
    assert_nothing_raised do 
      post = Mumblr::TextPost.new(tumblr_id: 1234)
      post.save
    end
    found = Mumblr::Post.find(1234)
    assert_not_nil found
    assert_equal found.tumblr_id, 1234
  end

  def test_saved_textpost_is_textpost
    post = Mumblr::TextPost.new(tumblr_id: 1234)
    post.save

    found = Mumblr::Post.find(1234)
    assert_equal found.type, "text"
    assert found.is_a?(Mumblr::TextPost)
  end

  def test_absent_post_not_found
    not_found = Mumblr::Post.find(1)
    assert not_found.nil?
  end

  def test_find_random_record
    Mumblr::TextPost.new(tumblr_id: 1).save
    Mumblr::TextPost.new(tumblr_id: 2).save
    Mumblr::LinkPost.new(tumblr_id: 3).save

    post = Mumblr::TextPost.random
    assert_not_nil post.tumblr_id
    assert post.is_a?(Mumblr::TextPost)
    assert post.tumblr_id != 3
  end

  def test_count_includes_only_relevant_type
    Mumblr::TextPost.new(tumblr_id: 1).save
    Mumblr::TextPost.new(tumblr_id: 2).save
    Mumblr::LinkPost.new(tumblr_id: 3).save

    assert_equal Mumblr::Post.count, 3
    assert_equal Mumblr::TextPost.count, 2
    assert_equal Mumblr::LinkPost.count, 1
  end

  def test_all_returns_only_relevant_type
    Mumblr::TextPost.new(tumblr_id: 1).save
    Mumblr::TextPost.new(tumblr_id: 2).save
    Mumblr::LinkPost.new(tumblr_id: 3).save

    Mumblr::TextPost.all.each do |post|
      assert post.is_a?(Mumblr::TextPost)
    end
    Mumblr::LinkPost.all.each do |post|
      assert post.is_a?(Mumblr::LinkPost)
    end
  end

  def test_valid_class_from_hash_type
    assert_equal Mumblr::Post.class_from_type('text'), Mumblr::TextPost
    assert_equal Mumblr::Post.class_from_type('link'), Mumblr::LinkPost
  end

  def test_invalid_class_from_hash_type
    assert_raise ArgumentError do
      Mumblr::Post.class_from_type('garbage')
    end
  end

  def test_fetched_post_has_valid_type
    Mumblr.blog = 'thelowlypeon'
    post = Mumblr::Post.find!(67719574870)
    assert post.is_a?(Mumblr::TextPost), "fetched post is a #{post.class.name}, expected Mumblr::TextPost"
  end

  def test_fetched_post_was_cached
    Mumblr.blog = 'thelowlypeon'
    presearch = Mumblr::Post.find(67719574870)
    presearch.destroy unless presearch.nil?

    post = Mumblr::Post.find!(67719574870)
    assert_not_nil post

    postsearch = Mumblr::Post.find(67719574870)
    assert_not_nil postsearch
    textsearch = Mumblr::TextPost.find(67719574870)
    assert_not_nil textsearch
  end
end
