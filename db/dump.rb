require 'emoji'
require 'json'
require 'rexml/document'

class UnicodeCharacter
  attr_reader :code, :description, :version, :aliases

  class CharListener
    CHAR_TAG = "char".freeze

    def self.parse(io, &block)
      REXML::Document.parse_stream(io, self.new(&block))
    end

    def initialize(&block)
      @callback = block
    end

    def tag_start(name, attributes)
      if CHAR_TAG == name
        @callback.call(
          attributes.fetch("cp") { return },
          attributes.fetch("na") { return },
          attributes.fetch("age", nil),
        )
      end
    end

    def method_missing(*) end
  end

  def self.index
    return @index if defined? @index
    @index = {}
    File.open(File.expand_path('../ucd.nounihan.grouped.xml', __FILE__)) do |source|
      CharListener.parse(source) do |char, desc, age|
        uc = UnicodeCharacter.new(char, desc, age)
        @index[uc.code] = uc
      end
    end
    @index
  end

  def self.fetch(code)
    code = code.to_s(16).rjust(4, '0') if code.is_a?(Integer)
    self.index.fetch(code)
  end

  def initialize(code, description, version)
    @code = code.downcase
    @description = description.downcase
    @version = version
    @aliases = []
    @references = []
  end

  def add_alias(string)
    @aliases.concat string.split(/\s*,\s*/)
  end

  def add_reference(code)
    @references << code.downcase
  end
end

unless $stdin.tty?
  codepoints = STDIN.read.chomp.codepoints.map { |code|
    UnicodeCharacter.fetch(code)
  }
  codepoints.each do |char|
    printf "%5s: %s", char.code.upcase, char.description
    printf " (%s)", char.version if char.version
    puts
  end
  exit
end

trap(:PIPE) { abort }

normalize = -> (raw) {
  raw.sub(Emoji::VARIATION_SELECTOR_16, '')
}

emojidesc = {}
File.open(File.expand_path('../emoji-test.txt', __FILE__)) do |file|
  file.each do |line|
    next if line =~ /^(#|$)/
    line = line.chomp.split('# ', 2)[1]
    emoji, description = line.split(' ', 2)
    emojidesc[normalize.(emoji)] = description
  end
end

items = []

for category, emojis in Emoji.apple_palette
  for raw in emojis
    emoji = Emoji.find_by_unicode(raw)
    unicode_version = emoji ? emoji.unicode_version : ''
    ios_version = emoji ? emoji.ios_version : ''

    unless raw.include?(Emoji::ZERO_WIDTH_JOINER)
      uchar = UnicodeCharacter.fetch(raw.codepoints[0])
      unicode_version = uchar.version unless uchar.version.nil?
    end

    description = emojidesc.fetch(normalize.(raw))

    if unicode_version == ''
      warn "#{description} (#{raw}) doesn't have Unicode version"
    end

    if ios_version == ''
      ios_version = '10.2'
    end

    items << {
      emoji: raw,
      description: description,
      category: category,
      aliases: emoji ? emoji.aliases : [description.gsub(/\W+/, '_').downcase],
      tags: emoji ? emoji.tags : [],
      unicode_version: unicode_version,
      ios_version: ios_version,
    }
  end
end

for emoji in Emoji.all.select(&:custom?)
  items << {
    aliases: emoji.aliases,
    tags: emoji.tags,
  }
end

puts JSON.pretty_generate(items)
  .gsub("\n\n", "\n")
  .gsub(/,\n( +)/) { "\n%s, " % $1[2..-1] }
