require 'emoji'

task :emoji do
  Dir["#{Emoji::PATH}/../images/*.png"].each do |src|
    cp src, "#{Rails.root}/public/images/emoji/"
  end
end
