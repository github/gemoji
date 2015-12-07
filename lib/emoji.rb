require 'emoji/collection'
require 'forwardable'
require 'json'

module Emoji
  extend self, Forwardable

  def data_file
    File.expand_path('../../db/emoji.json', __FILE__)
  end

  def images_path
    File.expand_path("../../images", __FILE__)
  end

  def_delegators :default_collection, :edit_emoji, :find_by_alias, :find_by_unicode

  def all
    default_collection.to_a
  end

  def create(name, &block)
    default_collection.add_emoji(name, &block)
  end

  def default_collection
    @default_collection ||= Collection.new.tap do |collection|
      raw = File.open(data_file, 'r:UTF-8') { |data| JSON.parse(data.read) }
      raw.each do |raw_emoji|
        collection.add_emoji(nil) do |emoji|
          raw_emoji.fetch('aliases').each { |name| emoji.add_alias(name) }
          if raw = raw_emoji['emoji']
            unicodes = [raw, raw.sub(VARIATION_SELECTOR_16, '') + VARIATION_SELECTOR_16].uniq
            unicodes.each { |uni| emoji.add_unicode_alias(uni) }
          end
          raw_emoji.fetch('tags').each { |tag| emoji.add_tag(tag) }
        end
      end
    end
  end

  VARIATION_SELECTOR_16 = "\u{fe0f}".freeze
  private_constant :VARIATION_SELECTOR_16
end
