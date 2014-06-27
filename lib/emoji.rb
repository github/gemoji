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
    @all ||= parse_data_file
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

  def names
    @names ||= names_index.keys.sort
  end

  def unicodes
    @unicodes ||= unicodes_index.keys
  end

  def custom
    @custom ||= all.map { |emoji|
      emoji.aliases if emoji.custom?
    }.compact.flatten.sort
  end

  def unicode_for(name)
    emoji = find_by_alias(name) { return nil }
    emoji.raw
  end

  def name_for(unicode)
    emoji = find_by_unicode(unicode) { return nil }
    emoji.name
  end

  def names_for(unicode)
    emoji = find_by_unicode(unicode) { return nil }
    emoji.aliases
  end

  private
    def create_index
      index = Hash.new { |hash, key| hash[key] = [] }
      yield index
      index
    end

    def parse_data_file
      raw = File.open(data_file, 'r:UTF-8') { |data| JSON.parse(data.read) }
      raw.map do |raw_emoji|
        char = Emoji::Character.new(raw_emoji['emoji'])
        raw_emoji.fetch('aliases').each { |name| char.add_alias(name) }
        raw_emoji.fetch('unicodes', []).each { |uni| char.add_unicode_alias(uni) }
        raw_emoji.fetch('tags').each { |tag| char.add_tag(tag) }
        char
      end
    end

    def names_index
      @names_index ||= create_index do |mapping|
        all.each do |emoji|
          emoji.aliases.each do |name|
            mapping[name] = emoji
          end
        end
      end
    end

    def unicodes_index
      @unicodes_index ||= create_index do |mapping|
        all.each do |emoji|
          emoji.unicode_aliases.each do |unicode|
            mapping[unicode] = emoji
          end
        end
      end
    end
end
