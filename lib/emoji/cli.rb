require 'emoji/extractor'
require 'fileutils'

module Emoji
  module CLI
    extend self

    def dispatch(argv)
      cmd = argv[0]
      argv = argv[1..-1]

      case cmd
      when "extract"
        public_send(cmd, argv)
      when "help", "--help", "-h"
        help
      else
        raise ArgumentError
      end

      return 0
    rescue ArgumentError
      $stderr.puts usage_text
      return 1
    end

    def help
      puts usage_text
    end

    def extract(argv)
      path = argv.shift
      raise ArgumentError if path.to_s.empty?

      Emoji::Extractor.new(64, path).extract!
      Dir["#{Emoji.images_path}/emoji/*.png"].each do |png|
        FileUtils.cp(png, File.join(path, File.basename(png)))
      end
    end

    def usage_text
      <<EOF
Usage: gemoji extract <path>
EOF
    end
  end
end
