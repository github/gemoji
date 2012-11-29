require 'emoji'

module Emoji
  class Railtie < ::Rails::Railtie
    railtie_name :emoji

    rake_tasks do
      load 'tasks/emoji.rake'
    end

    initializer 'emoji.initialize' do |app|
      app.config.assets.paths << Emoji.images_path
    end
  end
end
