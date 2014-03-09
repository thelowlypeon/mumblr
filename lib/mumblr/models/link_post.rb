module Mumblr

  class LinkPost < Post
    key :type, String, default: 'link'
    key :url, String
  end

end
