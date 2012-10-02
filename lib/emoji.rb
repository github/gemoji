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
end
