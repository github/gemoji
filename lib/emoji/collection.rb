require 'emoji/character'

module Emoji
  class Collection
    include Enumerable

    def initialize
      @all = []
      @names_index = {}
      @unicodes_index = {}
    end

    # Public: Initialize an Emoji::Character instance and yield it to the block.
    # The character is added to the collection.
    def add_emoji(name)
      emoji = Emoji::Character.new(name)
      @all << edit_emoji(emoji) { yield emoji if block_given? }
      emoji
    end

    # Public: Yield an emoji to the block and update the indices in case its
    # aliases or unicode_aliases lists changed.
    def edit_emoji(emoji)
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
      @names_index[name]
    end

    # Public: Find an emoji by its unicode character. Return nil if missing.
    def find_by_unicode(unicode)
      @unicodes_index[unicode]
    end

    # Public: Yield each emoji to the block. Return an Enumerator if no block is given.
    def each(&block)
      @all.each(&block)
    end
  end
end
