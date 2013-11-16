desc "Copy emoji to the Rails `public/images/emoji` directory"
task :emoji do
  require 'emoji'

  target = "#{Rake.original_dir}/public/images"
  mkdir_p target
  cp_r "#{Emoji.images_path}/emoji", target, preserve: true, remove_destination: true
end
