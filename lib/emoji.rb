module Emoji
  extend self

  IMAGES_PATH      = File.expand_path("../assets/images", __FILE__)
  JAVASCRIPTS_PATH = File.expand_path("../assets/javascripts", __FILE__)
  STYLESHEETS_PATH = File.expand_path("../assets/stylesheets", __FILE__)

  def images_path
    IMAGES_PATH
  end

  def javascripts_path
    JAVASCRIPTS_PATH
  end

  def stylesheets_path
    STYLESHEETS_PATH
  end

  def names
    @names ||= Dir["#{IMAGES_PATH}/emoji/*.png"].map { |fn| File.basename(fn, '.png') }
  end

  def replace(string)
    string.gsub(/:([a-z0-9\+\-_]+):/) do |message|
      name = $1.to_s.downcase
      if names.include?(name)
        %(<span class="emoji emoji-#{name}" title=":#{name}:"></span>)
      else
        message
      end
    end
  end
end

if defined? Rails::Engine
  require 'emoji/engine'
end
