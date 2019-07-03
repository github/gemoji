# encoding: utf-8
# frozen_string_literal: true

require 'emoji/character'
require 'json'

module Emoji
  extend self

  def data_file
    File.expand_path('../../db/emoji.json', __FILE__)
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

  private
    VARIATION_SELECTOR_16 = "\u{fe0f}".freeze

    # Characters which must have VARIATION_SELECTOR_16 to render as color emoji:
    TEXT_GLYPHS = [
      "\u{1f237}", # Japanese “monthly amount” button
      "\u{1f202}", # Japanese “service charge” button
      "\u{1f170}", # A button (blood type)
      "\u{1f171}", # B button (blood type)
      "\u{1f17e}", # O button (blood type)
      "\u{00a9}",  # copyright
      "\u{00ae}",  # registered
      "\u{2122}",  # trade mark
      "\u{3030}",  # wavy dash
      "\u{263a}",  # smiling face
      "\u{261D}",  # index pointing up
      "\u{270C}",  # victory hand
      "\u{270D}",  # writing hand
      "\u{2764}",  # red heart
      "\u{2763}",  # heavy heart exclamation
      "\u{2668}",  # hot springs
      "\u{2708}",  # airplane
      "\u{2600}",  # sun
      "\u{2601}",  # cloud
      "\u{2602}",  # umbrella
      "\u{2744}",  # snowflake
      "\u{2603}",  # snowman
      "\u{2660}",  # spade suit
      "\u{2665}",  # heart suit
      "\u{2666}",  # diamond suit
      "\u{2663}",  # club suit
      "\u{260e}",  # telephone
      "\u{2709}",  # envelope
      "\u{270F}",  # pencil
      "\u{2712}",  # black nib
      "\u{2702}",  # scissors
      "\u{26a0}",  # warning
      "\u{2B06}",  # up arrow
      "\u{2197}",  # up-right arrow
      "\u{27A1}",  # right arrow
      "\u{2198}",  # down-right arrow
      "\u{2B07}",  # down arrow
      "\u{2199}",  # down-left arrow
      "\u{2B05}",  # left arrow
      "\u{2196}",  # up-left arrow
      "\u{2195}",  # up-down arrow
      "\u{2194}",  # left-right arrow
      "\u{21A9}",  # right arrow curving left
      "\u{21AA}",  # left arrow curving right
      "\u{2934}",  # right arrow curving up
      "\u{2935}",  # right arrow curving down
      "\u{2721}",  # star of David
      "\u{262F}",  # yin yang
      "\u{271D}",  # latin cross
      "\u{25B6}",  # play button
      "\u{25C0}",  # reverse button
      "\u{23CF}",  # eject button
      "\u{2640}",  # female sign
      "\u{2642}",  # male sign
      "\u{267B}",  # recycling symbol
      "\u{2611}",  # ballot box with check
      "\u{2714}",  # heavy check mark
      "\u{2716}",  # heavy multiplication x
      "\u{303D}",  # part alternation mark
      "\u{2733}",  # eight-spoked asterisk
      "\u{2734}",  # eight-pointed star
      "\u{2747}",  # sparkle
      "\u{203C}",  # double exclamation mark
      "\u{2049}",  # exclamation question mark
      "\u{23}\u{20E3}",  # keycap: #
      "\u{2A}\u{20E3}",  # keycap: *
      "\u{30}\u{20E3}",  # keycap: 0
      "\u{31}\u{20E3}",  # keycap: 1
      "\u{32}\u{20E3}",  # keycap: 2
      "\u{33}\u{20E3}",  # keycap: 3
      "\u{34}\u{20E3}",  # keycap: 4
      "\u{35}\u{20E3}",  # keycap: 5
      "\u{36}\u{20E3}",  # keycap: 6
      "\u{37}\u{20E3}",  # keycap: 7
      "\u{38}\u{20E3}",  # keycap: 8
      "\u{39}\u{20E3}",  # keycap: 9
      "\u{2139}",  # information
      "\u{24C2}",  # circled M
      "\u{1F17F}", # P button
      "\u{3297}",  # Japanese “congratulations” button
      "\u{3299}",  # Japanese “secret” button
      "\u{25AA}",  # black small square
      "\u{25AB}",  # white small square
      "\u{25FB}",  # white medium square
      "\u{25FC}",  # black medium square
    ].freeze

    private_constant :VARIATION_SELECTOR_16, :TEXT_GLYPHS

    def parse_data_file
      data = File.open(data_file, 'r:UTF-8') do |file|
        JSON.parse(file.read, symbolize_names: true)
      end

      if "".respond_to?(:-@)
        # Ruby >= 2.3 this is equivalent to .freeze
        # Ruby >= 2.5 this will freeze and dedup
        dedup = lambda { |str| -str }
      else
        dedup = lambda { |str| str.freeze }
      end

      append_unicode = lambda do |emoji, raw|
        unless TEXT_GLYPHS.include?(raw) || emoji.unicode_aliases.include?(raw)
          emoji.add_unicode_alias(dedup.call(raw))
        end
      end

      data.each do |raw_emoji|
        self.create(nil) do |emoji|
          raw_emoji.fetch(:aliases).each { |name| emoji.add_alias(dedup.call(name)) }
          if raw = raw_emoji[:emoji]
            append_unicode.call(emoji, raw)
            start_pos = 0
            while found_index = raw.index(VARIATION_SELECTOR_16, start_pos)
              # register every variant where one VARIATION_SELECTOR_16 is removed
              raw_alternate = raw.dup
              raw_alternate[found_index] = ""
              append_unicode.call(emoji, raw_alternate)
              start_pos = found_index + 1
            end
            if start_pos > 0
              # register a variant with all VARIATION_SELECTOR_16 removed
              append_unicode.call(emoji, raw.gsub(VARIATION_SELECTOR_16, ""))
            else
              # register a variant where VARIATION_SELECTOR_16 is added
              append_unicode.call(emoji, "#{raw}#{VARIATION_SELECTOR_16}")
            end
          end
          raw_emoji.fetch(:tags).each { |tag| emoji.add_tag(dedup.call(tag)) }

          emoji.category = dedup.call(raw_emoji[:category])
          emoji.description = dedup.call(raw_emoji[:description])
          emoji.unicode_version = dedup.call(raw_emoji[:unicode_version])
          emoji.ios_version = dedup.call(raw_emoji[:ios_version])
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
