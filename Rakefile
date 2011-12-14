desc "List emoji unicode without a short name"
task :unnamed do
  unicode = Dir["images/unicode/*.png"].map { |fn| File.basename(fn) }

  named = Dir["images/*.png"]
    .select { |fn| File.symlink?(fn) }
    .map { |fn| File.basename(File.readlink(fn)) }

  puts unicode - named
end
