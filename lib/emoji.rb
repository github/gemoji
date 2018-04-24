# encoding: utf-8
require 'emoji/character'
require 'json'

module Emoji
  extend self

  def data_file
    File.expand_path('../../db/emoji.json', __FILE__)
  end

  def apple_palette_file
    File.expand_path('../../db/Category-Emoji.json', __FILE__)
  end

  def images_path
    File.expand_path("../../images", __FILE__)
  end

  def unicode_palette_file
    File.expand_path("../../db/emoji-test.txt", __FILE__)
  end

  def all
    return @all if defined? @all
    @all = []
    parse_data_file
    @all
  end

  def unicode_palette
    return @unicode_palette if defined? @unicode_palette
    data = []
    # CVDataTitle to Unicode group
    apple_to_unicode_mappings = {
      "EmojiCategory-People" => "Smileys & People",
      "EmojiCategory-Nature" => "Animals & Nature",
      "EmojiCategory-Foods" => "Food & Drink",
      "EmojiCategory-Places" => "Travel & Places",
      "EmojiCategory-Activity" => "Activities",
      "EmojiCategory-Objects" => "Objects",
      "EmojiCategory-Symbols" => "Symbols",
      "EmojiCategory-Flags" => "Flags",
    }
    groupMapping = {
      "Smileys & People" => {
        "CVDataTitle" => "EmojiCategory-People",
        image: "Emoji-HumanImage",
        "CVCategoryData" => { "Data" => [] }
      },
      "Animals & Nature" => {
        "CVDataTitle" => "EmojiCategory-Nature",
        image: "Emoji-NatureImage",
        "CVCategoryData" => { "Data" => [] }
      },
      "Food & Drink" => {
        "CVDataTitle" => "EmojiCategory-Foods",
        image: "Emoji-FoodsImage",
        "CVCategoryData" => { "Data" => [] }
      },
      "Travel & Places" => {
        "CVDataTitle" => "EmojiCategory-Places",
        image: "Emoji-PlacesImage",
        "CVCategoryData" => { "Data" => [] }
      },
      "Activities" => {
        "CVDataTitle" => "EmojiCategory-Activity",
        image: "Emoji-ActivityImage",
        "CVCategoryData" => { "Data" => [] }
      },
      "Objects" => {
        "CVDataTitle" => "EmojiCategory-Objects",
        image: "Emoji-ObjectsImage",
        "CVCategoryData" => { "Data" => [] }
      },
      "Symbols" => {
        "CVDataTitle" => "EmojiCategory-Symbols",
        image: "Emoji-SymbolImage",
        "CVCategoryData" => { "Data" => [] }
      },
      "Flags" => {
        "CVDataTitle" => "EmojiCategory-Flags",
        image: "Emoji-FlagsImage",
        "CVCategoryData" => { "Data" => [] }
      },
    }

    # Seed unicode groups with data from apple groups
    apple_categories = File.open(apple_palette_file, 'r:UTF-8') { |file| JSON.parse(file.read)["EmojiDataArray"] }
    apple_categories.each do |category|
      unicode_group_name = apple_to_unicode_mappings[category["CVDataTitle"]]
      unicode_group = groupMapping[unicode_group_name]
      unicode_group["CVCategoryData"]["Data"] = category["CVCategoryData"]["Data"].split(',')
    end
    currentGroup = {}
    File.foreach(unicode_palette_file) do |line|
      if line.start_with? '# group:'
        group = line.sub!('# group: ', '').strip
        if newGroup = groupMapping[group]
          if !currentGroup.empty?
            data.push(currentGroup)
          end
          currentGroup = newGroup
        end
      elsif !line.strip.empty? and !line.start_with? '#' and !line.include? "non-fully-qualified" and !line.include? 'keycap'
        _, comment = line.split("#").map(&:strip).reject(&:empty?)
        emoji, _ = comment.split(" ")
        if !currentGroup["CVCategoryData"]["Data"].include? emoji
          currentGroup["CVCategoryData"]["Data"].push(emoji)
        end
      end
    end
    data.push(currentGroup)
    {
      "EmojiDataArray" => data
    }
  end

  def apple_palette
    return @apple_palette if defined? @apple_palette
    @apple_palette = unicode_palette.fetch('EmojiDataArray').each_with_object({}) do |group, all|
      title = group.fetch('CVDataTitle').split('-', 2)[1]
      all[title] = group.fetch('CVCategoryData').fetch('Data').map do |raw|
        TEXT_GLYPHS.include?(raw) ? raw + VARIATION_SELECTOR_16 : raw
      end
    end
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

  private
    VARIATION_SELECTOR_16 = "\u{fe0f}".freeze
    ZERO_WIDTH_JOINER = "\u{200d}".freeze
    FEMALE_SYMBOL = "\u{2640}".freeze
    MALE_SYMBOL = "\u{2642}".freeze

    # Chars from Apple's palette which must have VARIATION_SELECTOR_16 to render:
    TEXT_GLYPHS = ["🈷", "🈂", "🅰", "🅱", "🅾", "©", "®", "™", "〰"].freeze

    def parse_data_file
      data = File.open(data_file, 'r:UTF-8') { |file| JSON.parse(file.read) }
      data.each do |raw_emoji|
        self.create(nil) do |emoji|
          raw_emoji.fetch('aliases').each { |name| emoji.add_alias(name) }
          if raw = raw_emoji['emoji']
            unicodes = [raw, raw.sub(VARIATION_SELECTOR_16, '') + VARIATION_SELECTOR_16].uniq
            unicodes.each { |uni| emoji.add_unicode_alias(uni) }
          end
          raw_emoji.fetch('tags').each { |tag| emoji.add_tag(tag) }

          emoji.category = raw_emoji['category']
          emoji.description = raw_emoji['description']
          emoji.unicode_version = raw_emoji['unicode_version']
          emoji.ios_version = raw_emoji['ios_version']
        end
      end

      # Add an explicit gendered variant to emoji that historically imply a gender
      data.each do |raw_emoji|
        raw = raw_emoji['emoji']
        next unless raw
        no_gender = raw.sub(/(#{VARIATION_SELECTOR_16})?#{ZERO_WIDTH_JOINER}(#{FEMALE_SYMBOL}|#{MALE_SYMBOL})/, '')
        next unless $2
        emoji = find_by_unicode(no_gender)
        next unless emoji
        edit_emoji(emoji) do
          emoji.add_unicode_alias(
            $2 == FEMALE_SYMBOL ?
              raw.sub(FEMALE_SYMBOL, MALE_SYMBOL) :
              raw.sub(MALE_SYMBOL, FEMALE_SYMBOL)
          )
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

# Preload emoji into memory
Emoji.all
