module Mumblr

  class LinkPost < Post
    key :type, String, default: 'link'
    key :title, String
    key :url, String
    key :description, String
  end

end
