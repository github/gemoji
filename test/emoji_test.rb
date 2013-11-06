require 'test_helper'

class EmojiTest < TestCase
  test "names array contains all the names" do
    assert Emoji.names.size > 100
    assert_equal Dir["#{Emoji.images_path}/emoji/*.png"].size, Emoji.names.size
  end

  test "unicodes array contains all the unicodes" do
    assert Emoji.unicodes.size > 100
    assert_equal Dir["#{Emoji.images_path}/emoji/unicode/*.png"].size, Emoji.unicodes.size
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

  Emoji.unicodes.each do |unicode|
    test "name for #{unicode}" do
      assert !Emoji.name_for(unicode).nil?
    end
  end
end
