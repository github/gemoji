task :emoji => :environment do
  require 'emoji'

  Dir["#{Emoji.images_path}/emoji/*.png"].each do |src|
    cp src, "#{Rails.root}/public/images/emoji/"
  end
end
