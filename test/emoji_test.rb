require 'test_helper'

class EmojiTest < TestCase
  test "fetching all emoji" do
    count = Emoji.all.size
    assert count > 845, "there were too few emojis: #{count}"
  end

  test "names array contains the names" do
    count = Emoji.names.size
    assert count > 845, "there were too few emoji names: #{count}"
  end

  test "unicodes array contains the unicodes" do
    min_size = Emoji.all.reject(&:custom?).size
    count = Emoji.unicodes.size
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

  test "emojis have tags" do
    emoji = Emoji.find_by_alias('smile')
    assert emoji.tags.include?('happy')
    assert emoji.tags.include?('joy')
    assert emoji.tags.include?('pleased')
  end

  Emoji.names.each do |name|
    test "#{name} is a valid name" do
      assert_match /^[\w\+\-]+$/, name
    end
  end

  test "custom array contains the non-Apple emoji" do
    assert Emoji.custom.include?("shipit")
    assert !Emoji.custom.include?("+1")
  end

  test "unicode for" do
    assert_equal "\u{1f6af}", Emoji.unicode_for("do_not_litter")
    assert_equal "\u{1f1e8}\u{1f1f3}", Emoji.unicode_for("cn")
    assert_equal nil, Emoji.unicode_for("$$$$$")
    assert_equal nil, Emoji.unicode_for(nil)
  end

  (Emoji.names - Emoji.custom).each do |name|
    test "unicode for #{name}" do
      assert !Emoji.unicode_for(name).nil?
    end
  end

  Emoji.custom.each do |name|
    test "no unicode for #{name}" do
      assert Emoji.unicode_for(name).nil?
    end
  end

  test "name for" do
    assert_equal "do_not_litter", Emoji.name_for("\u{1f6af}")
    assert_equal "cn", Emoji.name_for("\u{1f1e8}\u{1f1f3}")
    assert_equal nil, Emoji.name_for("$$$$$")
    assert_equal nil, Emoji.name_for(nil)
  end

  test "names_for" do
    assert_equal %w[hocho knife], Emoji.names_for("\u{1f52a}")
    assert_equal nil, Emoji.names_for("$$$$$")
  end

  Emoji.unicodes.each do |unicode|
    test "name for #{unicode}" do
      assert !Emoji.name_for(unicode).nil?
    end
  end

  test "support for unicode variation selectors" do
    assert_equal "heart", Emoji.name_for("\u{2764}")
    assert_equal "heart", Emoji.name_for("\u{2764}\u{fe0f}")
    assert_equal "\u{2764}\u{fe0f}", Emoji.unicode_for("heart")
  end
end
