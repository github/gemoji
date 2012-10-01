task :emoji => :environment do
  require 'emoji'

  Dir["#{Emoji::PATH}/../images/*.png"].each do |src|
    cp src, "#{Rails.root}/public/images/emoji/"
  end
end
