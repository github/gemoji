# frozen_string_literal: true

module EmojiTestParser
  VARIATION_SELECTOR_16 = "\u{fe0f}"
  SKIN_TONES = [
    "\u{1F3FB}", # light skin tone
    "\u{1F3FC}", # medium-light skin tone
    "\u{1F3FD}", # medium skin tone
    "\u{1F3FE}", # medium-dark skin tone
    "\u{1F3FF}", # dark skin tone
  ]
  HAIR_MODIFIERS = [
    "\u{1F9B0}", # red-haired
    "\u{1F9B1}", # curly-haired
    "\u{1F9B2}", # bald
    "\u{1F9B3}", # white-haired
  ]

  module_function

  def parse(filename)
    File.open(filename, "r:UTF-8") do |file|
      parse_file(file)
    end
  end

  def parse_file(io)
    data = []
    emoji_map = {}
    category = nil
    sub_category = nil

    io.each do |line|
      begin
        if line.start_with?("# group: ")
          _, group_name = line.split(":", 2)
          category = {
            name: group_name.strip,
            emoji: [],
          }
          data << category
          sub_category = nil
        elsif line.start_with?("# subgroup: ")
          _, group_name = line.split(":", 2)
          sub_category = {
            name: group_name.strip,
            emoji: [],
          }
          category[:emoji] << sub_category
        elsif line.start_with?("#") || line.strip.empty?
          next
        else
          row, desc = line.split("#", 2)
          desc = desc.strip.split(" ", 2)[1]
          codepoints, _ = row.split(";", 2)
          emoji_raw = codepoints.strip.split.map { |c| c.hex }.pack("U*")
          next if HAIR_MODIFIERS.include?(emoji_raw)
          emoji_normalized = emoji_raw
            .gsub(VARIATION_SELECTOR_16, "")
            .gsub(/(#{SKIN_TONES.join("|")})/o, "")
          emoji_item = emoji_map[emoji_normalized]
          if SKIN_TONES.any? { |s| emoji_raw.include?(s) }
            emoji_item[:skin_tones] = true if emoji_item
            next
          end
          if emoji_item
            emoji_item[:sequences] << emoji_raw
          else
            emoji_item = {
              sequences: [emoji_raw],
              description: desc,
            }
            emoji_map[emoji_normalized] = emoji_item
            sub_category[:emoji] << emoji_item
          end
        end
      rescue
        warn "line: %p" % line
        raise
      end
    end

    [emoji_map, data]
  end
end

if $0 == __FILE__
  html_output = false
  if ARGV[0] == "--html"
    ARGV.shift
    html_output = true
  end

  _, categories = EmojiTestParser.parse

  trap(:PIPE) { abort }

  if html_output
    puts "<!doctype html>"
    puts "<meta charset=utf-8>"
    for category in categories
      puts "<h2>#{category[:name]}</h2>"
      for sub_category in category[:emoji]
        puts "<h3>#{sub_category[:name]}</h3>"
        puts "<ol>"
        for char in sub_category[:emoji]
          puts "<li>"
          for sequence in char[:sequences]
            codepoints = sequence.unpack("U*").map { |c| c.to_s(16).upcase }.join(" ")
            printf '<span class=emoji title="%s">%s</span> ', codepoints, sequence
          end
          puts "#{char[:description]}</li>"
        end
        puts "</ol>"
      end
    end
  else
    require "json"
    puts JSON.pretty_generate(categories)
  end
end
