module Emoji
  class Character
    VARIATION_SELECTOR_16 = "\u{fe0f}".freeze

    # Inspect individual Unicode characters in a string by dumping its
    # codepoints in hexadecimal format.
    def self.hex_inspect(str)
      str.codepoints.map { |c| c.to_s(16).rjust(4, '0') }.join('-')
    end

    # Raw Unicode string for an emoji. Nil if emoji is non-standard.
    attr_reader :raw

    # True if the emoji is not a standard Emoji character.
    def custom?() !raw end

    # A list of names uniquely referring to this emoji.
    attr_reader :aliases

    def name() aliases.first end

    def add_alias(name)
      aliases << name
    end

    # A list of Unicode strings that uniquely refer to this emoji. By default,
    # this list includes the emoji's Unicode representation without the
    # variation selector character.
    attr_reader :unicode_aliases

    def add_unicode_alias(str)
      unicode_aliases << str
    end

    # A list of tags associated with an emoji. Multiple emojis can share the
    # same tags.
    attr_reader :tags

    def add_tag(tag)
      tags << tag
    end

    def initialize(raw)
      @raw = raw
      @aliases = []
      @unicode_aliases = []
      @tags = []

      # Automatically add a representation of this emoji without the variation
      # selector to unicode aliases:
      add_unicode_alias(raw.sub(VARIATION_SELECTOR_16, '')) if variation?
    end

    def inspect
      hex = '(%s)' % hex_inspect unless custom?
      %(#<#{self.class.name}:#{name}#{hex}>)
    end

    def variation?
      !custom? && raw.index(VARIATION_SELECTOR_16)
    end

    def hex_inspect
      self.class.hex_inspect(raw)
    end

    def image_filename
      if custom?
        '%s.png' % name
      else
        'unicode/%s.png' % hex_inspect
      end
    end
  end
end
