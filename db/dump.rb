# frozen_string_literal: true

require "i18n"
require 'emoji'
require 'json'
require_relative './emoji-test-parser'

I18n.config.available_locales = :en
items = []

_, categories = EmojiTestParser.parse(File.expand_path("../../vendor/unicode-emoji-test.txt", __FILE__))
seen_existing = {}

for category in categories
  for sub_category in category[:emoji]
    for emoji_item in sub_category[:emoji]
      raw = emoji_item[:sequences][0]
      existing_emoji = Emoji.find_by_unicode(raw) || Emoji.find_by_unicode("#{raw}\u{fe0f}")
      if seen_existing.key?(existing_emoji)
        existing_emoji = nil
      else
        seen_existing[existing_emoji] = true
      end
      description = emoji_item[:description].sub(/^E\d+(\.\d+)? /, '')
      output_item = {
        emoji: raw,
        description: description,
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
          aliases: [I18n.transliterate(description).gsub(/\W+/, '_').downcase],
          tags: [],
          unicode_version: "13.1",
          ios_version: "14.5",
        )
      end
      output_item[:skin_tones] = true if emoji_item[:skin_tones]
      items << output_item
    end
  end
end

missing_emoji = Emoji.all.reject { |e| e.custom? || seen_existing.key?(e) }
if missing_emoji.any?
  $stderr.puts "Error: these `emoji.json` entries were not matched:"
  $stderr.puts missing_emoji.map { |e| "%s (%s)" % [e.hex_inspect, e.name] }
  exit 1
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
