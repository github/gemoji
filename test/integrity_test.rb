require 'test_helper'
require 'json'

class IntegrityTest < TestCase
  test "missing aliases to unicode sources" do
    # List unicode files excluding those that are symlinked to
    unicode_files = Dir["#{Emoji.images_path}/emoji/unicode/*.png"]
    symlink_paths = unicode_files.select { |fn| File.symlink?(fn) }.map { |fn| File.realpath(fn) }
    unicode_files.reject! { |fn| symlink_paths.include?(File.realpath(fn)) }

    unicodes = unicode_files.map { |fn| File.basename(fn) }
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
          if unicode = Emoji.unicodes.detect { |u| u.codepoints.first == missing.codepoints.first }
            message << " - might be #{unicode} (#{point_pair(unicode)}) named #{Emoji.name_for(unicode)}"
          end
          message << "\n"
        end
      end
    end

    def point_pair(unicode)
      Array(unicode.codepoints).map { |c| c.to_s(16) }.join('-')
    end

    def db
      @db ||= JSON.parse(File.read(File.expand_path("../../db/Category-Emoji.json", __FILE__)))
    end

    def source_unicode_emoji
      @source_unicode_emoji ||= db["EmojiDataArray"].flat_map { |data| data["CVCategoryData"]["Data"].split(",") }
    end
end
