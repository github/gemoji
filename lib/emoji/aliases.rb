require 'yaml'
require 'emoji'

module Emoji
  EMPTY = [].freeze

  def alias_data
    alias_list = File.expand_path('../../../db/aliases.yml', __FILE__)
    YAML.load_file(alias_list)
  end

  def alias_mapping
    @alias_mapping ||= alias_data.each_with_object(Hash.new(EMPTY)) do |(name, aliases), mapping|
      key = unicode_for(name)
      mapping[key] = aliases
    end
  end

  def aliases_for(name)
    key = unicode_for(name)
    alias_mapping[key]
  end
end
