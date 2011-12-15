$:.unshift File.expand_path("../lib", __FILE__)

require 'emoji'
require 'sprockets'
require 'rake/clean'

Assets = Sprockets::Environment.new do |env|
  env.append_path "lib/assets/images"
  env.append_path "lib/assets/javascripts"
  env.append_path "lib/assets/stylesheets"
end

file "lib/assets/images/emoji.png" do |f|
  sh "montage images/*.png -background transparent -tile x#{Emoji.names.size} -geometry 20x20 #{f.name}"
end

file "lib/assets/javascripts/emoji.js" do |f|
  Assets["emoji.js"].write_to(f.name)
end

file "lib/assets/stylesheets/emoji.css" do |f|
  Assets["emoji.css"].write_to(f.name)
end

assets = [
  "lib/assets/images/emoji.png",
  "lib/assets/javascripts/emoji.js",
  "lib/assets/stylesheets/emoji.css"
]

assets.each { |asset| CLOBBER.include(asset) }

task :default => assets
