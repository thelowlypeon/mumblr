module Mumblr

  class TextPost < Post
    key :type, String, default: 'text'
    key :title, String
  end

end
