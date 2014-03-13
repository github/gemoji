require 'test_helper'
require 'json'

class IntegrityTest < TestCase
  test "images on disk correlate 1-1 with emojis" do
    images_on_disk = Dir["#{Emoji.images_path}/**/*.png"].map {|f| f.sub(Emoji.images_path, '') }
    expected_images = []

    Emoji.all.each do |emoji|
      image = '/emoji/%s' % emoji.image_filename
      assert images_on_disk.include?(image), "'#{image}' is missing on disk"
      expected_images << image
    end

    extra_images = images_on_disk - expected_images
    assert_equal 0, extra_images.size, "these images don't match any emojis: #{extra_images.inspect}"
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
