desc "Copy emoji to the Rails `public/images/emoji` directory"
task :emoji do
  require 'emoji'

  target = "#{Rake.original_dir}/public/images/emoji"

  mkdir_p "#{target}"
  Dir["#{Emoji.images_path}/emoji/*.png"].each do |src|
    cp src, "#{target}/"
  end

  mkdir_p "#{target}/unicode"
  Dir["#{Emoji.images_path}/emoji/unicode/*.png"].each do |src|
    cp src, "#{target}/unicode/"
  end
end

desc "Output an emoji.js helper containing current emoji names to `vendor/assets/javascripts/"
task :emoji_javascript_helper do
  require 'emoji'
  require 'json'

  target = "#{Rake.original_dir}/vendor/assets/javascripts"

  mkdir_p "#{target}"

  File.open(File.join(target, "emoji.js"), "w") do |file|
    file.puts "window.Emoji = { names: #{JSON.dump(Emoji.names)} };"
  end
end
