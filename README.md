gemoji
======

Emoji images and names. See the LICENSE for copyright information.


Installation
============

Add `gemoji` to you Gemfile.

``` ruby
gem 'gemoji', :require => 'emoji/railtie'
```


Example Rails Helper
====================

This would allow emojifying content such as: `it's raining :cats: and :dogs:!`

See the [Emoji cheat sheet](http://www.emoji-cheat-sheet.com) for more examples.

```ruby
module EmojiHelper
 def emojify(content)
    h(content).to_str.gsub(/:([a-z0-9\+\-_]+):/) do |match|
      if Emoji.names.include?($1)
        '<img alt="' + $1 + '" height="20" src="' + asset_path("emoji/#{$1}.png") + '" style="vertical-align:middle" width="20" />'
      else
        match
      end
    end.html_safe if content.present?
  end
end
```
