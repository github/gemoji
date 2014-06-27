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
  def create(raw)
    emoji = Emoji::Character.new(raw)
    self.all << edit_emoji(emoji) { yield emoji }
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

  def find_by_alias(name)
    names_index.fetch(name) {
      if block_given? then yield name
      else raise NotFound, "Emoji not found by name: %s" % name.inspect
      end
    }
  end

  def find_by_unicode(unicode)
    unicodes_index.fetch(unicode) {
      if block_given? then yield unicode
      else raise NotFound, "Emoji not found from unicode: %s" % Emoji::Character.hex_inspect(unicode)
      end
    }
  end

  private
    def parse_data_file
      raw = File.open(data_file, 'r:UTF-8') { |data| JSON.parse(data.read) }
      raw.each do |raw_emoji|
        self.create(raw_emoji['emoji']) do |emoji|
          raw_emoji.fetch('aliases').each { |name| emoji.add_alias(name) }
          raw_emoji.fetch('unicodes', []).each { |uni| emoji.add_unicode_alias(uni) }
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
