require 'test_helper'
require 'json'
require 'digest/md5'

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

  test "images on disk have no duplicates" do
    hashes = Hash.new { |h,k| h[k] = [] }
    Dir["#{Emoji.images_path}/**/*.png"].each do |image_file|
      checksum = Digest::MD5.file(image_file).to_s
      hashes[checksum] << image_file
    end

    hashes.each do |checksum, filenames|
      assert_equal 1, filenames.length,
        "These images share the same checksum: " +
        filenames.map {|f| f.sub(Emoji.images_path, '') }.join(', ')
    end
  end

  test "images on disk are 64x64" do
    mismatches = []
    Dir["#{Emoji.images_path}/**/*.png"].each do |image_file|
      width, height = png_dimensions(image_file)
      unless width == 64 && height == 64
        mismatches << "%s: %dx%d" % [
          image_file.sub(Emoji.images_path, ''),
          width,
          height
        ]
      end
    end
    assert_equal ["/emoji/shipit.png: 75x75"], mismatches
  end

  test "missing or incorrect unicodes" do
    missing = source_unicode_emoji - Emoji.all.map(&:raw).compact
    assert_equal 0, missing.size, missing_unicodes_message(missing)
  end

  private
    def missing_unicodes_message(missing)
      "Missing or incorrect unicodes:\n".tap do |message|
        missing.each do |raw|
          emoji = Emoji::Character.new(nil)
          emoji.add_unicode_alias(raw)
          message << "#{emoji.raw}  (#{emoji.hex_inspect})"
          codepoint = emoji.raw.codepoints[0]
          if candidate = Emoji.all.detect { |e| !e.custom? && e.raw.codepoints[0] == codepoint }
            message << " - might be #{candidate.raw}  (#{candidate.hex_inspect}) named #{candidate.name}"
          end
          message << "\n"
        end
      end
    end

    def db
      @db ||= JSON.parse(File.read(File.expand_path("../../db/Category-Emoji.json", __FILE__)))
    end

    def source_unicode_emoji
      @source_unicode_emoji ||= db["EmojiDataArray"].flat_map { |data| data["CVCategoryData"]["Data"].split(",") }
    end

    def png_dimensions(file)
      png = File.open(file, "rb") { |f| f.read(1024) }
      png.unpack("x16N2")
    end
end
