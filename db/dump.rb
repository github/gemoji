require 'json'
require 'yaml'
require 'emoji'
require 'emoji/aliases'

names_list = File.expand_path('../NamesList.txt', __FILE__)
emoji_list = File.expand_path('../Category-Emoji.json', __FILE__)

class UnicodeCharacter
  attr_reader :code, :description

  @index = {}
  class << self
    attr_reader :index

    def fetch(code, *args, &block)
      code = code.to_s(16).rjust(4, '0') if code.is_a?(Integer)
      index.fetch(code, *args, &block)
    end
  end

  def initialize(code, description)
    @code = code.downcase
    @description = description.downcase
    @aliases = []
    @references = []

    self.class.index[@code] = self
  end

  def raw
    @code.split('-').map {|c| c.to_i(16).chr(Encoding::UTF_8) }.join('')
  end

  def add_alias(string)
    @aliases.concat string.split(/\s*,\s*/)
  end

  def add_reference(code)
    @references << code.downcase
  end
end

char = nil

File.foreach(names_list) do |line|
  case line
  when /^[A-F0-9]{4,5}\t/
    code, desc = line.chomp.split("\t", 2)
    char = UnicodeCharacter.new(code, desc)
  when /^\t= /
    char.add_alias($')
  when /^\tx .+ - ([A-F0-9]{4,5})\)$/
    char.add_reference($1)
  end
end

json = JSON.parse(File.read(emoji_list))
emojis = json['EmojiDataArray'].flat_map {|data| data['CVCategoryData']['Data'].split(',') }

trap(:PIPE) { abort }

for emoji in emojis
  char = UnicodeCharacter.fetch(emoji.codepoints.first)
  names = Emoji.names_for(emoji)
  alt_names = Emoji.aliases_for(names.first)

  puts "#{emoji}  #{char.description}"
  puts "  = #{names.join(', ')}"
  puts "  ~ #{alt_names.join(', ')}" if alt_names.any?
end
