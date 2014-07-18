require 'emoji/character'
require 'json'

module Emoji
  extend self

  NotFound = Class.new(IndexError)

  def data_file
    File.expand_path('../../db/emoji.json', __FILE__)
  end

  def images_path
    File.expand_path("../../images", __FILE__)
  end

  def all
    return @all if defined? @all
    @all = []
    parse_data_file
    @all
  end

  # Public: Initialize an Emoji::Character instance and yield it to the block.
  # The character is added to the `Emoji.all` set.
  def create(name)
    emoji = Emoji::Character.new(name)
    self.all << edit_emoji(emoji) { yield emoji if block_given? }
    emoji
  end

  # Public: Yield an emoji to the block and update the indices in case its
  # aliases or unicode_aliases lists changed.
  def edit_emoji(emoji)
    @names_index ||= Hash.new
    @unicodes_index ||= Hash.new

    yield emoji

    emoji.aliases.each do |name|
      @names_index[name] = emoji
    end
    emoji.unicode_aliases.each do |unicode|
      @unicodes_index[unicode] = emoji
    end

    emoji
  end

  # Public: Find an emoji by its aliased name. Return nil if missing.
  def find_by_alias(name)
    fetch_by_alias name, nil
  end

  # Public: Find an emoji by its unicode character. Return nil if missing.
  def find_by_unicode(unicode)
    fetch_by_unicode unicode, nil
  end

  # Public: Fetch an emoji by its aliased name. If missing, return the default
  # value if provided, call the default block if provided, or raise NotFound.
  def fetch_by_alias(name, *default_value, &default_block)
    default_block ||= MISSING_ALIAS if default_value.empty?
    names_index.fetch name, *default_value, &default_block
  end

  # Public: Fetch an emoji by its Unicode character. If missing, return the
  # default value if provided, call the default block if provided, or raise
  # NotFound.
  def fetch_by_unicode(unicode, *default_value, &default_block)
    default_block ||= MISSING_UNICODE if default_value.empty?
    unicodes_index.fetch unicode, *default_value, &default_block
  end

  private
    MISSING_ALIAS = lambda { |name| raise NotFound, "Emoji not found by name: %s" % name.inspect }
    MISSING_UNICODE = lambda { |unicode| raise NotFound, "Emoji not found from unicode: %s" % Emoji::Character.hex_inspect(unicode) }
    VARIATION_SELECTOR_16 = "\u{fe0f}".freeze

    def parse_data_file
      raw = File.open(data_file, 'r:UTF-8') { |data| JSON.parse(data.read) }
      raw.each do |raw_emoji|
        self.create(nil) do |emoji|
          raw_emoji.fetch('aliases').each { |name| emoji.add_alias(name) }
          unicodes = Array(raw_emoji['emoji']) + raw_emoji.fetch('unicodes', [])
          unicodes.each { |uni|
            emoji.add_unicode_alias(uni)
            # Automatically add a representation of this emoji without the variation
            # selector to unicode aliases:
            if uni.index(VARIATION_SELECTOR_16)
              emoji.add_unicode_alias(uni.sub(VARIATION_SELECTOR_16, ''))
            end
          }
          raw_emoji.fetch('tags').each { |tag| emoji.add_tag(tag) }
        end
      end
    end

    def names_index
      all unless defined? @all
      @names_index
    end

    def unicodes_index
      all unless defined? @all
      @unicodes_index
    end
end
