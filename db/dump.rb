# frozen_string_literal: true

require 'emoji'
require 'json'
require_relative './emoji-test'

items = []

_, categories = EmojiTestParser.parse

for category in categories
  for sub_category in category[:emoji]
    for emoji_item in sub_category[:emoji]
      raw = emoji_item[:sequences][0]
      existing_emoji = Emoji.find_by_unicode(raw) || Emoji.find_by_unicode("#{raw}\u{fe0f}")
      output_item = {
        emoji: raw,
        description: emoji_item[:description],
        category: category[:name],
      }
      if existing_emoji
        output_item.update(
          aliases: existing_emoji.aliases,
          tags: existing_emoji.tags,
          unicode_version: existing_emoji.unicode_version,
          ios_version: existing_emoji.ios_version,
        )
      else
        output_item.update(
          aliases: [emoji_item[:description].gsub(/\W+/, '_').downcase],
          tags: [],
          unicode_version: "11.0",
          ios_version: "12.1",
        )
      end
      output_item[:skin_tones] = true if emoji_item[:skin_tones]
      items << output_item
    end
  end
end

for emoji in Emoji.all.select(&:custom?)
  items << {
    aliases: emoji.aliases,
    tags: emoji.tags,
  }
end

trap(:PIPE) { abort }

puts JSON.pretty_generate(items)
  .gsub("\n\n", "\n")
  .gsub(/,\n( +)/) { "\n%s, " % $1[2..-1] }
