require 'test/unit'
require 'mumblr'

class MumblrTest < Test::Unit::TestCase

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

end
