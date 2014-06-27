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

  test "fetching emoji by alias" do
    emoji = Emoji.find_by_alias('smile')
    assert_equal "\u{1f604}", emoji.raw
  end

  test "emoji alias not found" do
    error = assert_raises Emoji::NotFound do
      Emoji.find_by_alias('$$$')
    end
    assert_equal %(Emoji not found by name: "$$$"), error.message
  end

  test "emoji by alias fallback block" do
    emoji = Emoji.find_by_alias('hello') { |name| name.upcase }
    assert_equal 'HELLO', emoji
  end

  test "fetching emoji by unicode" do
    emoji = Emoji.find_by_unicode("\u{1f604}")
    assert_equal 'smile', emoji.name
  end

  test "emoji unicode not found" do
    error = assert_raises Emoji::NotFound do
      Emoji.find_by_unicode("\u{1234}\u{abcd}")
    end
    assert_equal %(Emoji not found from unicode: 1234-abcd), error.message
  end

  test "emoji by unicode fallback block" do
    emoji = Emoji.find_by_unicode("\u{1234}") { |u| "not-#{u}-found" }
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
end
