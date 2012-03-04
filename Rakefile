$:.unshift File.expand_path("../lib", __FILE__)

require 'emoji'
require 'sprockets'
require 'rake/clean'

Assets = Sprockets::Environment.new do |env|
  env.append_path Emoji.path
  env.append_path File.join(Emoji.path, 'assets')
end

file "lib/emoji.png" do |f|
  Assets["emoji.png"].write_to(f.name)
end

# We're generating a static image and putting that into the asset pipeline
# instead of putting the .erb file there directly because we saw Rails' asset
# digest was different between servers on deploy and suspect image generation.
file "lib/assets/images/emoji/index.png" do |f|
  Assets["emoji.png"].write_to(f.name)
end

file "lib/emoji.js" do |f|
  Assets["javascripts/emoji/index.js.erb"].write_to(f.name)
end

file "lib/emoji.css" do |f|
  Assets["stylesheets/emoji/index.css.erb"].write_to(f.name)
end

assets = [
  "lib/emoji.png",
  "lib/emoji.js",
  "lib/emoji.css",
  "lib/assets/images/emoji/index.png"
]

assets.each { |asset| CLOBBER.include(asset) }

task :default => [:clobber] + assets
