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
    unicodes = mapping.fetch(name, nil)
    unicodes.last if unicodes
  end

  def name_for(unicode)
    names = names_for(unicode)
    names.last if names
  end

  def names_for(unicode)
    inverted_mapping.fetch(unicode, nil)
  end

  private
    def create_index
      index = Hash.new { |hash, key| hash[key] = [] }
      yield index
      index
    end

    def mapping
      @mapping ||= create_index do |mapping|
        emoji_path = "#{images_path}/emoji"

        Dir["#{emoji_path}/*.png"].each do |filename|
          name = File.basename(filename, ".png")

          if File.symlink?(filename)
            unicode_filename = "#{emoji_path}/#{File.readlink(filename)}"

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
      @inverted_mapping ||= create_index do |inverted_mapping|
        mapping.each do |name, unicodes|
          next if unicodes.nil?
          unicodes.each do |unicode|
            inverted_mapping[unicode] << name
          end
        end
      end
    end
end
