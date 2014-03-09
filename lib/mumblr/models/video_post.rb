module Mumblr

  class VideoPost < Post
    key :type, String, default: 'video'
    key :caption, String
    key :player, String
  end

end
