require 'rake/clean'

desc "List emoji unicode without a short name"
task :unnamed do
  unicode = Dir["images/unicode/*.png"].map { |fn| File.basename(fn) }

  named = Dir["images/*.png"]
    .select { |fn| File.symlink?(fn) }
    .map { |fn| File.basename(File.readlink(fn)) }

  puts unicode - named
end

desc "List custom emoji"
task :custom do
  custom = Dir["images/*.png"]
    .select { |fn| !File.symlink?(fn) }
    .map { |fn| File.basename(fn) }

  puts custom
end

directory "dist/"
CLOBBER.include "dist/"

file "dist/emoji.css" => ["dist/"] + Dir["images/*.png"] do |f|
  css = <<-CSS
.emoji {
  display: inline-block;
  background: url("emoji.png") top left no-repeat;
  width: 20px;
  height: 20px;
  vertical-align: middle;
}
  CSS

  Dir["images/*.png"].each_with_index do |fn, i|
    fn = File.basename(fn, '.png')
    css += ".emoji-#{fn} { background-position: 0px -#{i*20}px; }\n"
  end

  File.open(f.name, 'w') { |f| f.write css }
end

file "dist/emoji.png" => ["dist/"] + Dir["images/*.png"] do |f|
  n = Dir["images/*.png"].size
  sh "montage images/*.png -background transparent -tile x#{n} -geometry 20x20 #{f.name}"
end

task :sprite => ["dist/emoji.png", "dist/emoji.css"]
