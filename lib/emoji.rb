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
    Array(mapping[name]).last
  end

  def name_for(unicode)
    inverted_mapping[unicode]
  end

  private
    def mapping
      @mapping ||= {}.tap do |mapping|
        emoji_path = "#{images_path}/emoji"

        Dir["#{emoji_path}/*.png"].each do |filename|
          name = File.basename(filename, ".png")

          if File.symlink?(filename)
            unicode_filename = "#{emoji_path}/#{File.readlink(filename)}"
            mapping[name] = []

            loop do
              codepoints = unicode_filename.match(/unicode\/([\da-f\-]+)\.png/)[1]
              mapping[name] << codepoints.split("-").map(&:hex).pack("U*")

              if File.symlink?(unicode_filename)
                unicode_filename = "#{emoji_path}/unicode/#{File.readlink(unicode_filename)}"
              else
                break
              end
            end
          else
            mapping[name] = nil
          end
        end
      end
    end

    def inverted_mapping
      @inverted_mapping ||= {}.tap do |inverted_mapping|
        mapping.each do |name, unicodes|
          next if unicodes.nil?
          unicodes.each do |unicode|
            inverted_mapping[unicode] = name
          end
        end
      end
    end
end
