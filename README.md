gemoji
======
Emoji images and names. See the LICENSE for copyright information.


Installation
------------
Add `gemoji` to you Gemfile

``` ruby
gem 'gemoji'
```


Example Rails Helper
--------------------
This would allow emojifying content such as: `it's raining :cats: and :dogs:!`

See the [Emoji cheat sheet](http://www.emoji-cheat-sheet.com) for more examples.

```ruby
module EmojiHelper
 def emojify(content)
    h(content).to_str.gsub(/:([a-z0-9\+\-_]+):/) do |match|
      if Emoji.names.include?($1)
        image_tag asset_path("emoji/#{$1}.png"), :alt => $1, :size => '20x20', :style => 'vertical-align: middle'
      else
        match
      end
    end.html_safe if content.present?
  end
end
```
