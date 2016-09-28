require 'emoji'

module Emoji
  class Extractor
    EMOJI_TTF = "/System/Library/Fonts/Apple Color Emoji.ttc"

    attr_reader :size, :images_path

    def initialize(size, images_path)
      @size = size
      @images_path = images_path
    end

    def extract!
      File.open(EMOJI_TTF, 'rb') do |file|
        font_offsets = parse_ttc(file)
        file.pos = font_offsets[0]
        tables = parse_tables(file)
        glyph_index = extract_glyph_index(file, tables)

        each_glyph_bitmap(file, tables, glyph_index) do |glyph_name, type, binread|
          if glyph_name =~ /^u[0-9A-F]{4}/ && glyph_name !~ /\.[1-5]($|\.)/
            File.open("#{images_path}/#{glyph_name}.#{type}", 'wb') do |png|
              png.write binread.call
            end
          end
        end
      end
    end

  private

    # https://www.microsoft.com/typography/otspec/otff.htm
    def parse_ttc(io)
      header_name = io.read(4).unpack('a*')[0]
      raise unless "ttcf" == header_name
      header_version, num_fonts = io.read(4*2).unpack('l>N')
      # parse_version(header_version) #=> 2.0
      io.read(4 * num_fonts).unpack('N*')
    end

    def parse_tables(io)
      sfnt_version, num_tables = io.read(4 + 2*4).unpack('Nn')
      # sfnt_version #=> 0x00010000
      num_tables.times.each_with_object({}) do |_, tables|
        tag, checksum, offset, length = io.read(4 + 4*3).unpack('a4N*')
        tables[tag] = {
          checksum: checksum,
          offset: offset,
          length: length,
        }
      end
    end

    GlyphIndex = Struct.new(:length, :name_index, :names) do
      def name_for(glyph_id)
        index = name_index[glyph_id]
        names[index - 257]
      end

      def each(&block)
        length.times(&block)
      end

      def each_with_name
        each do |glyph_id|
          yield glyph_id, name_for(glyph_id)
        end
      end
    end

    def extract_glyph_index(io, tables)
      postscript_table = tables.fetch('post')
      io.pos = postscript_table[:offset]
      end_pos = io.pos + postscript_table[:length]

      parse_version(io.read(32).unpack('l>')[0]) #=> 2.0
      num_glyphs = io.read(2).unpack('n')[0]
      glyph_name_index = io.read(2*num_glyphs).unpack('n*')

      glyph_names = []
      while io.pos < end_pos
        length = io.read(1).unpack('C')[0]
        glyph_names << io.read(length)
      end

      GlyphIndex.new(num_glyphs, glyph_name_index, glyph_names)
    end

    # https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6sbix.html
    def each_glyph_bitmap(io, tables, glyph_index)
      io.pos = sbix_offset = tables.fetch('sbix')[:offset]
      strike = extract_sbix_strike(io, glyph_index.length, size)

      glyph_index.each_with_name do |glyph_id, glyph_name|
        glyph_offset = strike[:glyph_data_offset][glyph_id]
        next_glyph_offset = strike[:glyph_data_offset][glyph_id + 1]

        if glyph_offset && next_glyph_offset && glyph_offset < next_glyph_offset
          io.pos = sbix_offset + strike[:offset] + glyph_offset
          x, y, type = io.read(2*2 + 4).unpack('s2A4')
          yield glyph_name, type, -> { io.read(next_glyph_offset - glyph_offset - 8) }
        end
      end
    end

    def extract_sbix_strike(io, num_glyphs, image_size)
      sbix_offset = io.pos
      version, flags, num_strikes = io.read(2*2 + 4).unpack('n2N')
      strike_offsets = num_strikes.times.map { io.read(4).unpack('N')[0] }

      strike_offsets.each do |strike_offset|
        io.pos = sbix_offset + strike_offset
        ppem, resolution = io.read(4*2).unpack('n2')
        next unless ppem == size

        data_offsets = io.read(4 * (num_glyphs+1)).unpack('N*')
        return {
          ppem: ppem,
          resolution: resolution,
          offset: strike_offset,
          glyph_data_offset: data_offsets,
        }
      end
      return nil
    end

    def parse_version(num)
      major = num >> 16
      minor = num & 0xFFFF
      "#{major}.#{minor}"
    end
  end
end
