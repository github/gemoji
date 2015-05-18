require 'emoji'

module Emoji
  module Tables
    def self.all_byte_sequences
      @all_byte_sequences ||= begin
        all = Emoji.all.flat_map { |e| e.unicode_aliases }.compact
        all.map { |e| e.bytes }
      end
    end

    def self.generate_length_tables
      groups = all_byte_sequences.group_by { |seq| seq.first }

      groups.each do |k, v|
        v.map! { |seq| seq.size }
        v.uniq!
        v.sort!
        v.reverse!
      end

      groups = groups.reduce({}) { |h, (k,v)| (h[v] ||= []) << k; h}
      byte_array = Array.new(256) { 0 }
      tags_width = groups.keys.map { |k| k.size }.max + 1

      code = "static const long emoji_byte_lengths[][#{tags_width}] = {\n"
      code << "\t{0},\n"

      groups.each_with_index do |(len_tags, magic_bytes), idx|
        code << "\t{" + (len_tags + [0]).join(', ') + "},\n" 

        magic_bytes.each do |b|
          byte_array[b] = idx + 1
        end
      end

      code << "};\n\n"
      code << "static const int8_t emoji_magic_bytes[] =\n"
      code << "{" + byte_array.map(&:to_s).join(', ') + "};\n"
      code
    end
  end
end
