require 'emoji/engine'
require 'emoji/version'

module Emoji
  def self.images_path
    File.expand_path("../../vendor/assets/images", __FILE__)
  end

  def self.names
    @names ||= Dir["#{images_path}/emoji/*.png"].map do |filename|
      File.basename(filename, '.png')
    end
  end
end
