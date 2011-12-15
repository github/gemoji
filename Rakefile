require 'rake/clean'

desc "List custom emoji"
task :custom do
  custom = Dir["images/*.png"]
    .select { |fn| !File.symlink?(fn) }
    .map { |fn| File.basename(fn) }

  puts custom
end

directory "dist/"
CLOBBER.include "dist/"

require 'erb'

image_deps = ["dist/"] + Dir["images/*.png"]

file "dist/emoji.css" => image_deps do |f|
  emoji = Dir["images/*.png"].map { |fn| File.basename(fn, '.png') }
  css = ERB.new(File.read("lib/emoji.css.erb")).result(binding)
  File.open(f.name, 'w') { |f| f.write css }
end

file "dist/emoji.js" => image_deps do |f|
  emoji = Dir["images/*.png"].map { |fn| File.basename(fn, '.png') }
  js = ERB.new(File.read("lib/emoji.js.erb")).result(binding)
  File.open(f.name, 'w') { |f| f.write js }
end

file "dist/emoji.png" => image_deps do |f|
  n = Dir["images/*.png"].size
  sh "montage images/*.png -background transparent -tile x#{n} -geometry 20x20 #{f.name}"
end

task :sprite => ["dist/emoji.png", "dist/emoji.css", "dist/emoji.js"]
