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
    Mumblr.blog = @@default_blog
  end

  def test_saved_textpost_found_by_generic_search
    assert_nothing_raised do 
      post = Mumblr::TextPost.new(tumblr_id: 1234)
      post.save
    end
    found = Mumblr::Post.find(1234, false)
    assert_not_nil found
    assert_equal found.tumblr_id, 1234
  end

  def test_saved_textpost_is_textpost
    post = Mumblr::TextPost.new(tumblr_id: 1234)
    post.save

    found = Mumblr::Post.find(1234, false)
    assert_equal found.type, "text"
    assert found.is_a?(Mumblr::TextPost)
  end

  def test_absent_post_not_found
    not_found = Mumblr::Post.find(1, false)
    assert not_found.nil?
  end

  def test_absent_post_not_found_or_fetched
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
    post = Mumblr::Post.find(67719574870, true)
    assert post.is_a?(Mumblr::TextPost), "fetched post is a #{post.class.name}, expected Mumblr::TextPost"
  end

  def test_fetched_post_was_cached
    Mumblr.blog = 'thelowlypeon'
    presearch = Mumblr::Post.find(67719574870, false)
    presearch.destroy unless presearch.nil?

    post = Mumblr::Post.find(67719574870, true)
    assert_not_nil post

    postsearch = Mumblr::Post.find(67719574870, false)
    assert_not_nil postsearch
    textsearch = Mumblr::TextPost.find(67719574870, false)
    assert_not_nil textsearch
  end

  def test_photoset_created_properly
    Mumblr.blog = 'thelowlypeon'
    photoset = Mumblr::PhotosetPost.find(76743812654, true)
    assert_not_nil photoset
    assert_not_nil photoset.photos

    set = Mumblr::Post.find(76743812654, false)
    assert_not_nil set
    assert_not_nil photoset.photos
    assert_not_nil photoset.photos[0].alt_sizes[0]['url']
  end

  def test_query_by_tags
    post = Mumblr::Post.find(67719574870, true)
    post.tags.each do |tag|
      found = Mumblr::Post.tagged(tag).first
      assert_not_nil found
    end
  end

  def test_fetch_by_tag
    posts = Mumblr::Post.tagged!('chicago')
    assert_not_nil posts.first, "Posts is empty but should have one element"
    posts.each do |post|
      assert post.tags.collect {|el| el.downcase }.include?('chicago'), "Post #{post.tumblr_id} is not tagged with chicago"
    end
  end

  def test_fetch_private_post
    assert_nothing_raised do
      Mumblr.configuration.include_private = false
      post = Mumblr::Post.find(79321092514, true)
      assert_nil post

      Mumblr.configuration.include_private = true
      post = Mumblr::Post.find(79321092514, true)
      assert_not_nil post
      assert_equal post.state, 'private'
    end
  end

  def test_duplicates_caught_and_updated_instead_of_inserted
    tumblr_id = 67719574870
    found = Mumblr::Post.find(tumblr_id, true)
    count_before = Mumblr::Post.where(tumblr_id: tumblr_id).count
    unless found.nil?
      assert_nothing_raised do
        duplicate = Mumblr::Post.new({tumblr_id: tumblr_id, type: found.type})
        duplicate.save
        count_after = Mumblr::Post.where(tumblr_id: tumblr_id).count
        assert_equal count_before, count_after, "Count before #{count_before} != count after #{count_after}. found: #{found.to_json}"
      end
    end
  end
end
