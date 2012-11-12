require 'emoji'
require 'rails'

module Emoji
  class Engine < Rails::Engine
    rake_tasks do
      load "tasks/emoji.rake"
    end

    initializer :emoji, :group => :assets do |app|
      app.config.assets.paths << Emoji.images_path
    end
  end
end
