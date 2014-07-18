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
    refute_nil Emoji.find_by_alias('smile')
  end

  test "finding nonexistent emoji by alias returns nil" do
    assert_nil Emoji.find_by_alias('$$$')
  end

  test "finding emoji by unicode" do
    refute_nil Emoji.find_by_unicode("\u{1f604}")
  end

  test "finding nonexistent emoji by unicode returns nil" do
    assert_nil Emoji.find_by_unicode("\u{1234}")
  end

  test "fetching emoji by alias" do
    emoji = Emoji.fetch_by_alias('smile')
    assert_equal "\u{1f604}", emoji.raw
  end

  test "fetching nonexistent emoji by alias raises NotFound if neither default value nor block is given" do
    error = assert_raises Emoji::NotFound do
      Emoji.fetch_by_alias('$$$')
    end
    assert_equal %(Emoji not found by name: "$$$"), error.message
  end

  test "fetching nonexistent emoji by alias returns default value" do
    assert_equal 'default', Emoji.fetch_by_alias('hello', 'default')
  end

  test "fetching nonexistent emoji by alias returns result of default block" do
    emoji = Emoji.fetch_by_alias('hello', &:upcase)
    assert_equal 'HELLO', emoji
  end

  test "fetching emoji by unicode" do
    emoji = Emoji.fetch_by_unicode("\u{1f604}")
    assert_equal 'smile', emoji.name
  end

  test "fetching nonexistent emoji unicode raises NotFound if neither default value nor block is given" do
    error = assert_raises Emoji::NotFound do
      Emoji.fetch_by_unicode("\u{1234}\u{abcd}")
    end
    assert_equal %(Emoji not found from unicode: 1234-abcd), error.message
  end

  test "fetching nonexistent emoji by unicode returns default value" do
    assert_equal 'default', Emoji.fetch_by_unicode("\u{1234}", 'default')
  end

  test "fetching nonexistent emoji by unicode returns result of default block" do
    emoji = Emoji.fetch_by_unicode("\u{1234}") { |u| "not-#{u}-found" }
    assert_equal "not-\u{1234}-found", emoji
  end

  test "unicode_aliases" do
    emoji = Emoji.find_by_unicode("\u{1f237}")
    assert_equal ["\u{1f237}", "\u{6708}"], emoji.unicode_aliases
  end

  test "unicode_aliases includes form without variation selector" do
    emoji = Emoji.find_by_alias("heart")
    assert_equal ["\u{2764}\u{fe0f}", "\u{2764}"], emoji.unicode_aliases
  end

  test "emojis have tags" do
    emoji = Emoji.find_by_alias('smile')
    assert emoji.tags.include?('happy')
    assert emoji.tags.include?('joy')
    assert emoji.tags.include?('pleased')
  end

  test "emojis have valid names" do
    Emoji.all.each do |emoji|
      assert_match /^[\w\+\-]+$/, emoji.name
    end
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
