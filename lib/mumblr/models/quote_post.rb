module Mumblr

  class QuotePost < Post
    key :type, String, default: 'quote'
    key :text, String
    key :source, String
  end

end
