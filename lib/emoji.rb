module Emoji
  PATH = File.expand_path("..", __FILE__)

  def self.path
    PATH
  end

  def self.images_path
    File.join(path, "assets/images")
  end

  def self.names
    @names ||= Dir["#{PATH}/../images/*.png"].sort.map { |fn| File.basename(fn, '.png') }
  end

  if defined? Rails::Engine
    class Engine < Rails::Engine
      rake_tasks do
        load "tasks/emoji.rake"
      end
    end
  end
end
