require 'test_helper'

class IntegrityTest < TestCase
  test "missing aliases to unicode sources" do
    unicodes = Dir["#{Emoji.images_path}/emoji/unicode/*.png"].map { |fn| File.basename(fn) }
    aliases  = Dir["#{Emoji.images_path}/emoji/*.png"].select { |fn| File.symlink?(fn) }.map { |fn| File.basename(fn) }
    used     = aliases.map { |name| File.basename(File.readlink("#{Emoji.images_path}/emoji/#{name}")) }.uniq
    unnamed  = unicodes - used

    assert_equal 0, unnamed.size, unnamed
  end

  test "missing or incorrect unicodes" do
    missing = source_unicode_emoji - Emoji.unicodes
    assert_equal 0, missing.size, missing_unicodes_message(missing)
  end

  private
    def missing_unicodes_message(missing)
      "Missing or incorrect unicodes:\n".tap do |message|
        missing.each do |missing|
          message << "#{missing} (#{point_pair(missing)})"
          Emoji.unicodes.each do |unicode|
            if (unicode.codepoints & missing.codepoints).any?
              message << " - might be #{unicode} (#{point_pair(unicode)}) named #{Emoji.name_for(unicode)}"
            end
          end
          message << "\n"
        end
      end
    end

    def point_pair(unicode)
      Array(unicode.codepoints).map { |c| c.to_s(16) }.join('-')
    end

    # http://www.unicode.org/Public/UNIDATA/EmojiSources.txt
    # I think this list is missing the newer emoji added in iOS6
    def emoji_source_file
      File.expand_path("../fixtures/EmojiSources.txt", __FILE__)
    end

    def source_unicode_emoji
      @source_unicode_emoji ||= [].tap do |codepoints|
        File.open(emoji_source_file).each_line do |line|
          unless line =~ /^#/ || line.strip == ""
            values = line.split(";").first.split()
            codepoints << values unless white_space_codepoints.include?(values[0])
          end
        end
      end.map { |c| c.map(&:hex).pack("U*") }
    end

    def white_space_codepoints
      %w(2002 2003 2005)
    end
end
