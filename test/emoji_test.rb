require 'test_helper'

class EmojiTest < TestCase
  test "fetching all emoji" do
    count = Emoji.all.size
    assert count > 845, "there were too few emojis: #{count}"
  end

  test "unicodes set contains the unicodes" do
    min_size = Emoji.all.reject(&:custom?).size
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
    assert_equal "\u{1f604}", Emoji.find_by_unicode("\u{1f604}").raw
  end

  test "finding nonexistent emoji by unicode returns nil" do
    assert_nil Emoji.find_by_unicode("\u{1234}")
  end

  test "unicode_aliases" do
    emoji = Emoji.find_by_unicode("\u{2728}")
    assert_equal ["\u{2728}", "\u{2728}\u{fe0f}"], emoji.unicode_aliases
  end

  test "unicode_aliases includes alternate position of VARIATION_SELECTOR_16" do
    emoji = Emoji.find_by_unicode("\u{0031}\u{fe0f}\u{20e3}")
    assert_equal ["\u{0031}\u{fe0f}\u{20e3}", "\u{0031}\u{20e3}\u{fe0f}"], emoji.unicode_aliases
  end

  test "unicode_aliases doesn't necessarily include form without VARIATION_SELECTOR_16" do
    emoji = Emoji.find_by_unicode("\u{00a9}\u{fe0f}")
    assert_equal ["\u{00a9}\u{fe0f}"], emoji.unicode_aliases
  end

  test "unicode_aliases for emoji that have gender variant include form with explicit gender" do
    male_spy = Emoji.find_by_unicode("\u{1f575}\u{fe0f}")
    assert_equal male_spy, Emoji.find_by_unicode("\u{1f575}\u{fe0f}\u{200d}\u{2642}\u{fe0f}")
  end

  test "emojis have tags" do
    emoji = Emoji.find_by_alias('smile')
    assert emoji.tags.include?('happy')
    assert emoji.tags.include?('joy')
    assert emoji.tags.include?('pleased')
  end

  test "emojis have valid names" do
    aliases = Emoji.all.flat_map(&:aliases)

    invalid = []
    alias_count = Hash.new(0)
    aliases.each do |name|
      alias_count[name] += 1
      invalid << name if name !~ /\A[\w+-]+\Z/
    end

    duplicates = alias_count.select { |_, count| count > 1 }.keys

    assert_equal [], invalid, "some emoji have invalid names"
    assert_equal [], duplicates, "some emoji aliases have duplicates"
  end

  test "missing or incorrect unicodes" do
    source_unicode_emoji = Emoji.apple_palette.values.flatten
    missing = source_unicode_emoji - Emoji.all.flat_map(&:unicode_aliases)

    message = "Missing or incorrect unicodes:\n"
    missing.each do |raw|
      message << "#{raw}  (#{Emoji::Character.hex_inspect(raw)})"
      codepoint = raw.codepoints[0]
      if candidate = Emoji.all.detect { |e| !e.custom? && e.raw.codepoints[0] == codepoint }
        message << " - might be #{candidate.raw}  (#{candidate.hex_inspect}) named #{candidate.name}"
      end
      message << "\n"
    end

    assert_equal 0, missing.size, message
  end

  test "emoji have category" do
    missing = Emoji.all.select { |e| !e.custom? && e.category.to_s.empty? }
    assert_equal [], missing.map(&:name), "some emoji don't have a category"

    emoji = Emoji.find_by_alias('family_man_woman_girl')
    assert_equal 'People', emoji.category
  end

  test "emoji have description" do
    missing = Emoji.all.select { |e| !e.custom? && e.description.to_s.empty? }
    assert_equal [], missing.map(&:name), "some emoji don't have a description"

    emoji = Emoji.find_by_alias('family_man_woman_girl')
    assert_equal 'family: man, woman, girl', emoji.description
  end

  test "emoji have Unicode version" do
    emoji = Emoji.find_by_alias('family_man_woman_girl')
    assert_equal '6.0', emoji.unicode_version
  end

  test "emoji have iOS version" do
    missing = Emoji.all.select { |e| !e.custom? && e.ios_version.to_s.empty? }
    assert_equal [], missing.map(&:name), "some emoji don't have an iOS version"

    emoji = Emoji.find_by_alias('family_man_woman_girl')
    assert_equal '8.3', emoji.ios_version
  end

  test "custom emojis" do
    custom = Emoji.all.select(&:custom?)
    assert custom.size > 0

    custom.each do |emoji|
      assert_nil emoji.raw
      assert_equal [], emoji.unicode_aliases
    end
  end

  test "custom emoji names" do
    custom_names = Emoji.all.select(&:custom?).map(&:name)
    assert custom_names.include?("shipit")
    assert !custom_names.include?("+1")
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
