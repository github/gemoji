desc "Checks for missing aliases to unicode sources"
task :unnamed do
  unicodes = Dir["./images/emoji/unicode/*.png"].map { |fn| File.basename(fn) }
  aliases = Dir["./images/emoji/*.png"].select { |fn| File.symlink?(fn) }.map { |fn| File.basename(fn) }
  used_unicodes = aliases.map { |name| File.basename(File.readlink("./images/emoji/#{name}")) }.uniq
  puts unicodes - used_unicodes
end
