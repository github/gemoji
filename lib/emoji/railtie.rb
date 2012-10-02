require 'emoji'
require 'rails'

module Emoji
  class Engine < Rails::Engine
    rake_tasks do
      load "tasks/emoji.rake"
    end
  end
end
