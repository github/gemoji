module Emoji
  extend self

  def images_path
    File.expand_path("../../images", __FILE__)
  end

  def names
    @names ||= mapping.keys.sort
  end

  def unicodes
    @unicodes ||= inverted_mapping.keys
  end

  def custom
    @custom ||= mapping.select { |name, unicode| unicode.nil? }.keys.sort
  end

  def unicode_for(name)
    mapping[name]
  end

  def name_for(unicode)
    inverted_mapping[unicode]
  end

  def mapping
    @mapping ||= {}.tap do |mapping|
      Dir["#{images_path}/emoji/*.png"].each do |filename|
        name = File.basename(filename, ".png")

        if File.symlink?(filename)
          codepoints = File.readlink(filename).match(/unicode\/([\da-f\-]+)\.png/)[1]
          mapping[name] = codepoints.split("-").map(&:hex).pack("U*")
        else
          mapping[name] = nil
        end
      end
    end
  end

  def inverted_mapping
    @inverted_mapping ||= mapping.reject { |name, unicode| unicode.nil? }.invert
  end
end
