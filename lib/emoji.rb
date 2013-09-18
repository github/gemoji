module Emoji
  PATH = File.expand_path("..", __FILE__)

  def self.path
    PATH
  end

  def self.images_path
    File.expand_path("../../images", __FILE__)
  end

  def self.names
    @names ||= Dir["#{images_path}/emoji/*.png"].sort.map { |fn| File.basename(fn, '.png') }
  end

  def self.unicodes
    unicode_emoji_map.keys
  end

  def self.to_unicode(name)
    emoji_unicode_map[name]
  end

  def self.from_unicode(unicode)
    unicode_emoji_map[unicode]
  end

private

  def self.emoji_unicode_map
    unless @emoji_unicode_map
      @emoji_unicode_map = {}
      names.each do |name|
        filename = "#{images_path}/emoji/#{name}.png"
        if File.symlink?(filename)
          match = /unicode\/([\da-f\-]+)\.png/.match File.readlink(filename)
          @emoji_unicode_map[name] = match[1].split('-').map(&:hex).pack('U*')
        end
      end
    end

    @emoji_unicode_map
  end

  def self.unicode_emoji_map
    @unicode_emoji_map ||= emoji_unicode_map.invert
  end

end
