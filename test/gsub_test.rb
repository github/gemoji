require_relative './test_helper'

class GsubTest < TestCase

  def random_letters
    @random_letters ||= ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + [' '] * 10 + ['%', '-']
  end

  def random_string(n)
    random_letters.sample(n).join
  end

  def all_emojis
    @all_emojis ||= Emoji.all.flat_map { |e| e.unicode_aliases }.compact
  end

  def test_replace_fuzz_testing
    emoji = all_emojis.shuffle
    fuzz = ""
    expected = ""

    emoji.each do |emoji|
      rnd = random_string(rand(20))
      fuzz << rnd << emoji
      expected << rnd << ":#{Emoji.find_by_unicode(emoji).name}:"
    end

    result = Emoji.gsub_unicode(fuzz) { |emoji| ":#{emoji.name}:" }
    assert_equal expected, result
  end
end
