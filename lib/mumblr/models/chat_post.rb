module Mumblr

  class ChatPost < Post
    key :type, String, default: 'chat'
    key :title, String
    key :body, String
    key :dialog, String
  end

end
