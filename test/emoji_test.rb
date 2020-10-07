require 'test_helper'
require_relative '../db/emoji-test-parser'

class EmojiTest < TestCase
  test "fetching all emoji" do
    count = Emoji.all.size
    assert count > 845, "there were too few emojis: #{count}"
  end

  test "unicodes set contains the unicodes" do
    min_size = Emoji.all.size
    count = Emoji.all.map(&:unicode_aliases).flatten.size
    assert count > min_size, "there were too few unicode mappings: #{count}"
  end

  test "finding emoji by alias" do
    assert_equal 'smile', Emoji.find_by_alias('smile').name
  end

  test "finding nonexistent emoji by alias returns nil" do
    assert_nil Emoji.find_by_alias('$$$')
  end

  test "finding emoji by unicode" do
    emoji = Emoji.find_by_unicode("\u{1f604}") # grinning face with smiling eyes
    assert_equal "\u{1f604}", emoji.raw
  end

  test "finding nonexistent emoji by unicode returns nil" do
    assert_nil Emoji.find_by_unicode("\u{1234}")
  end

  test "unicode_aliases" do
    emoji = Emoji.find_by_unicode("\u{2728}") # sparkles
    assert_equal ["2728", "2728-fe0f"], emoji.unicode_aliases.map { |u| Emoji::Character.hex_inspect(u) }
  end

  test "unicode_aliases doesn't necessarily include form without VARIATION_SELECTOR_16" do
    emoji = Emoji.find_by_unicode("\u{00a9}\u{fe0f}") # copyright symbol
    assert_equal ["00a9-fe0f"], emoji.unicode_aliases.map { |u| Emoji::Character.hex_inspect(u) }
  end

  test "emojis have tags" do
    emoji = Emoji.find_by_alias('smile')
    assert emoji.tags.include?('happy')
    assert emoji.tags.include?('joy')
    assert emoji.tags.include?('pleased')
  end

  GENDER_EXCEPTIONS = [
    "man_with_gua_pi_mao",
    "woman_with_headscarf",
    "pregnant_woman",
    "isle_of_man",
    "blonde_woman",
    /^couple(kiss)?_/,
    /^family_/,
  ]

  test "emojis have valid names" do
    aliases = Emoji.all.flat_map(&:aliases)

    gender_mismatch = []
    to_another_gender = lambda do |name|
      case name
      when *GENDER_EXCEPTIONS then name
      else
        name.sub(/(?<=^|_)(?:wo)?man(?=_|$)/) do |match|
          match == "woman" ? "man" : "woman"
        end
      end
    end

    invalid = []
    alias_count = Hash.new(0)
    aliases.each do |name|
      alias_count[name] += 1
      invalid << name if name !~ /\A[\w+-]+\Z/
      another_gender = to_another_gender.call(name)
      gender_mismatch << another_gender unless aliases.include?(another_gender)
    end

    duplicates = alias_count.select { |_, count| count > 1 }.keys

    assert_equal [], invalid, "some emoji have invalid names"
    assert_equal [], duplicates, "some emoji aliases have duplicates"
    assert_equal [], gender_mismatch, "missing gender variants"
  end

  test "missing or incorrect unicodes" do
    emoji_map, _ = EmojiTestParser.parse(File.expand_path("../../vendor/unicode-emoji-test.txt", __FILE__))
    source_unicode_emoji = emoji_map.values
    supported_sequences = Emoji.all.flat_map(&:unicode_aliases)
    text_glyphs = Emoji.const_get(:TEXT_GLYPHS)

    missing = 0
    message = "Missing or incorrect unicodes:\n"
    source_unicode_emoji.each do |emoji|
      emoji[:sequences].each do |raw|
        next if text_glyphs.include?(raw) || Emoji.find_by_unicode(raw)
        message << "%s (%s)" % [Emoji::Character.hex_inspect(raw), emoji[:description]]
        if found = Emoji.find_by_unicode(raw.gsub("\u{fe0f}", ""))
          message << " - could be %s (:%s:)" % [found.hex_inspect, found.name]
        end
        message << "\n"
        missing += 1
      end
    end

    assert_equal 0, missing, message
  end

  test "emoji have category" do
    missing = Emoji.all.select { |e| e.category.to_s.empty? }
    assert_equal [], missing.map(&:name), "some emoji don't have a category"

    emoji = Emoji.find_by_alias('family_man_woman_girl')
    assert_equal 'People & Body', emoji.category

    categories = Emoji.all.map(&:category).uniq.compact
    assert_equal [
      "Smileys & Emotion",
      "People & Body",
      "Animals & Nature",
      "Food & Drink",
      "Travel & Places",
      "Activities",
      "Objects",
      "Symbols",
      "Flags",
    ], categories
  end

  test "emoji have description" do
    missing = Emoji.all.select { |e| e.description.to_s.empty? }
    assert_equal [], missing.map(&:name), "some emoji don't have a description"

    emoji = Emoji.find_by_alias('family_man_woman_girl')
    assert_equal 'family: man, woman, girl', emoji.description
  end

  test "emoji have Unicode version" do
    emoji = Emoji.find_by_alias('family_man_woman_girl')
    assert_equal '6.0', emoji.unicode_version
  end

  test "emoji have iOS version" do
    missing = Emoji.all.select { |e| e.ios_version.to_s.empty? }
    assert_equal [], missing.map(&:name), "some emoji don't have an iOS version"

    emoji = Emoji.find_by_alias('family_man_woman_girl')
    assert_equal '8.3', emoji.ios_version
  end

  test "skin tones" do
    smiley = Emoji.find_by_alias("smiley")
    assert_equal false, smiley.skin_tones?

    wave = Emoji.find_by_alias("wave")
    assert_equal true, wave.skin_tones?
  end

  test "no custom emojis" do
    custom = Emoji.all.select(&:custom?)
    assert 0, custom.size
  end

  test "create" do
    emoji = Emoji.create("music") do |char|
      char.add_unicode_alias "\u{266b}"
      char.add_unicode_alias "\u{266a}"
      char.add_tag "notes"
      char.add_tag "eighth"
    end

    begin
      assert_equal emoji, Emoji.all.last
      assert_equal emoji, Emoji.find_by_alias("music")
      assert_equal emoji, Emoji.find_by_unicode("\u{266a}")
      assert_equal emoji, Emoji.find_by_unicode("\u{266b}")

      assert_equal "\u{266b}", emoji.raw
      assert_equal "unicode/266b.png", emoji.image_filename
      assert_equal %w[music], emoji.aliases
      assert_equal %w[notes eighth], emoji.tags
    ensure
      Emoji.all.pop
    end
  end

  test "create with custom filename" do
    emoji = Emoji.create("music") do |char|
      char.image_filename = "some_path/my_emoji.gif"
    end

    begin
      assert_equal "some_path/my_emoji.gif", emoji.image_filename
    ensure
      Emoji.all.pop
    end
  end

  test "create without block" do
    emoji = Emoji.create("music")

    begin
      assert_equal emoji, Emoji.find_by_alias("music")
      assert_equal [], emoji.unicode_aliases
      assert_equal [], emoji.tags
      assert_equal "music.png", emoji.image_filename
    ensure
      Emoji.all.pop
    end
  end

  test "edit" do
    emoji = Emoji.find_by_alias("weary")

    emoji = Emoji.edit_emoji(emoji) do |char|
      char.add_alias "whining"
      char.add_unicode_alias "\u{1f629}\u{266a}"
      char.add_tag "complaining"
    end

    begin
      assert_equal emoji, Emoji.find_by_alias("weary")
      assert_equal emoji, Emoji.find_by_alias("whining")
      assert_equal emoji, Emoji.find_by_unicode("\u{1f629}")
      assert_equal emoji, Emoji.find_by_unicode("\u{1f629}\u{266a}")

      assert_equal %w[weary whining], emoji.aliases
      assert_includes emoji.tags, "complaining"
    ensure
      emoji.aliases.pop
      emoji.unicode_aliases.pop
      emoji.tags.pop
    end
  end
end
