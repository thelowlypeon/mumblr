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
      #tumblr provides no solid way of avoiding duplicates,
      # so just clear all photos before adding them back
      self.photos.clear
      arr.each do |photo_hash|
        self.photos << Mumblr::Photo.new(photo_hash)
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
    key :filename,      String

    belongs_to :photoset_post, :class_name => "Mumblr::PhotosetPost"

    def initialize(data)
      if data.is_a?(Hash) && !data.has_key?(:filename)
        data[:filename] = Mumblr::Photo.filename_from_data(data)
      end
      super data
    end

    def self.filename_from_data(data)
      if data.has_key?('alt_sizes') && !data['alt_sizes'].empty? && data['alt_sizes'][0].has_key?('url')
        url = data['alt_sizes'][0]['url']
        filname = url[/.*\/([A-Za-z0-9_\-]+\.(png|jpg|jpeg))$/]
      end
    end

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
