require 'emoji/character'
require 'json'

module Emoji
  extend self

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
    names_index[name]
  end

  # Public: Find an emoji by its unicode character. Return nil if missing.
  def find_by_unicode(unicode)
    unicodes_index[unicode]
  end

  def unicodes_regex
    all unless defined? @all
    #.sort.reverse in order to match '1f44d-1f3ff' before '1f44d'
    #'*' is escaped (in emojione collection set 2016)
    @unicodes_regex ||= /#{@unicodes_index.keys.sort.reverse.join('|').gsub('*','\*')}/
  end

  private
    VARIATION_SELECTOR_16 = "\u{fe0f}".freeze

    def parse_data_file
      raw = File.open(data_file, 'r:UTF-8') { |data| JSON.parse(data.read) }
      raw.each do |raw_emoji|
        self.create(nil) do |emoji|
          raw_emoji.fetch('aliases').each { |name| emoji.add_alias(name) }
          if raw = raw_emoji['emoji']
            unicodes = [raw, raw.sub(VARIATION_SELECTOR_16, '') + VARIATION_SELECTOR_16].uniq
            unicodes.each { |uni| emoji.add_unicode_alias(uni) }
          end
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
