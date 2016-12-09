module Emoji
  class Railtie < Rails::Railtie
    initializer "preload emoji data" do
      Emoji.all
    end
  end
end
