# frozen_string_literal: true

require 'emoji'
require 'json'
require_relative './emoji-test-parser'

items = []

_, categories = EmojiTestParser.parse(File.expand_path("../../vendor/unicode-emoji-test.txt", __FILE__))
seen_existing = {}

for category in categories
  for sub_category in category[:emoji]
    for emoji_item in sub_category[:emoji]
      unicodes = emoji_item[:sequences].sort_by(&:bytesize)
      existing_emoji = nil
      unicodes.detect do |raw|
        existing_emoji = Emoji.find_by_unicode(raw)
      end
      existing_emoji = nil if seen_existing.key?(existing_emoji)
      output_item = {
        emoji: unicodes[0],
        description: emoji_item[:description],
        category: category[:name],
      }
      if existing_emoji
        eu = existing_emoji.unicode_aliases
        preferred_raw = eu.size == 2 && eu[0] == "#{eu[1]}\u{fe0f}" ? eu[1] : eu[0]
        output_item.update(
          emoji: preferred_raw,
          aliases: existing_emoji.aliases,
          tags: existing_emoji.tags,
          unicode_version: existing_emoji.unicode_version,
          ios_version: existing_emoji.ios_version,
        )
        seen_existing[existing_emoji] = true
      else
        output_item.update(
          aliases: [emoji_item[:description].gsub(/\W+/, '_').downcase],
          tags: [],
          unicode_version: "12.0",
          ios_version: "13.0",
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
