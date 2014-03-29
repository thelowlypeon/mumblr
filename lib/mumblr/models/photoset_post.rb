module Mumblr

  class PhotosetPost < Post
    key :type, String, default: 'photo'
    key :caption, String

    many :photos, :class_name => "Mumblr::Photo"

    def initialize(hash)
      photos = hash['photos']
      hash.delete('photos')
      super
      self.photos = photos
    end

    def photos=(arr)
      if arr.is_a?(String)
        arr = JSON.parse arr
      end
      arr.each do |photo|
        self.photos << Mumblr::Photo.new(photo)
      end
    end
  end

  class Photo
    include MongoMapper::EmbeddedDocument

    key :caption,       String
    key :alt_sizes,     Array #[{width, height, url},{...}]
    key :original_size, Hash #{width, height, url},{...}
    key :panorama_size, Hash #{width, height, url},{...}
    key :exif,          String

    belongs_to :photoset_post, :class_name => "Mumblr::PhotosetPost"

    def large
      if self.alt_sizes.present?
        self.alt_sizes[0]
      end
    end

    def large!
      if self.alt_sizes.present?
        self.alt_sizes[0]['url']
      end
    end
  end

end
