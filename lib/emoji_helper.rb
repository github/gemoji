module EmojiHelper
  def emojify(content)
    h(content).to_str.gsub(/:([a-z0-9\+\-_]+):/) do |match|
      if Emoji.names.include?($1)
        image_tag("emoji/#{$1}.png", :size => "20x20", :style => "vertical-align:middle")
      else
        match
      end
    end.html_safe if content.present?
  end
end
