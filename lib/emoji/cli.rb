# frozen_string_literal: true

require 'fileutils'
require 'optparse'

module Emoji
  module CLI
    extend self

    InvalidUsage = Class.new(RuntimeError)

    def dispatch(argv)
      cmd = argv[0]
      argv = argv[1..-1]

      case cmd
      when "extract"
        public_send(cmd, argv)
      when "help", "--help", "-h"
        help
      else
        raise InvalidUsage
      end

      return 0
    rescue InvalidUsage, OptionParser::InvalidArgument, OptionParser::InvalidOption => err
      unless err.message == err.class.to_s
        $stderr.puts err.message
        $stderr.puts
      end
      $stderr.puts usage_text
      return 1
    end

    def help
      puts usage_text
    end

    def extract(argv)
      # OptionParser.new do |opts|
      #   opts.on("--size=64", Integer) do |size|
      # end.parse!(argv)

      raise InvalidUsage unless argv.size == 1
      path = argv[0]

      Dir["#{Emoji.images_path}/*.png"].each do |png|
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
