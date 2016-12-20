require 'test_helper'
require 'json'
require 'digest/md5'

unless images_extracted = File.directory?(File.join(Emoji.images_path, 'unicode'))
  warn "Warning: skipping image integrity tests. Run \`rake images/unicode' on macOS to enable."
end

class IntegrityTest < TestCase
  test "images on disk correlate 1-1 with emojis" do
    images_on_disk = Dir["#{Emoji.images_path}/**/*.png"].map {|f| f.sub(Emoji.images_path, '') }
    expected_images = Emoji.all.map { |emoji| '/%s' % emoji.image_filename }

    missing_images = expected_images - images_on_disk
    assert_equal 0, missing_images.size, "these images are missing on disk:\n  #{missing_images.join("\n  ")}\n"

    extra_images = images_on_disk - expected_images
    assert_equal 0, extra_images.size, "these images don't match any emojis:\n  #{extra_images.join("\n  ")}\n"
  end

  test "images on disk have no duplicates" do
    hashes = Hash.new { |h,k| h[k] = [] }
    Emoji.all.each do |emoji|
      checksum = Digest::MD5.file(File.join(Emoji.images_path, emoji.image_filename)).to_s
      hashes[checksum] << emoji
    end

    hashes.each do |checksum, emojis|
      assert_equal 1, emojis.length,
        "These images share the same checksum: " +
        emojis.map(&:image_filename).join(', ')
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
    assert_equal ["/shipit.png: 75x75"], mismatches
  end

  private

  def png_dimensions(file)
    png = File.open(file, "rb") { |f| f.read(1024) }
    png.unpack("x16N2")
  end
end if images_extracted
