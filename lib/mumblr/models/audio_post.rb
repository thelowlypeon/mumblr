module Mumblr

  class AudioPost < Post
    key :type, String, default: 'audio'
    key :caption, String
    key :player, String
    key :plays, Integer
    key :album_art, String
    key :artist, String
    key :album, String
    key :track_name, String
    key :track_number, Integer
    key :year, Integer
  end

end
