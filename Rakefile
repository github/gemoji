$:.unshift File.expand_path("../lib", __FILE__)

require 'emoji'
require 'sprockets'
require 'rake/clean'

Assets = Sprockets::Environment.new do |env|
  env.append_path Emoji.path
end

file "lib/emoji.png" do |f|
  sh "montage images/*.png -background transparent -tile x#{Emoji.names.size} -geometry 20x20 #{f.name}"
end

file "lib/emoji.js" do |f|
  Assets["emoji.js"].write_to(f.name)
end

file "lib/emoji.css" do |f|
  Assets["emoji.css"].write_to(f.name)
end

assets = [
  "lib/emoji.png",
  "lib/emoji.js",
  "lib/emoji.css"
]

assets.each { |asset| CLOBBER.include(asset) }

task :default => [:clobber] + assets
