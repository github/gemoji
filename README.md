Emoji
=====

Shared Emoji assets between GitHub, Campfire, and BCX.

Contributing
------------

### Designers

Drop a 64x64 png into `images/` and commit it.

### Others

Rerun `rake` to rebuild static assets and sprites. (Trying to make this step unnecessary)

Deploying
---------

### GitHub

1. Run `rake emoji` in app root

### Campfire

1. Push changes to 37signals/emoji
2. Update emoji version in config/externals.yml
3. Run `cap local externals:setup` in app root
4. Run `rake emoji` in app root
5. Run `Rails.cache.clear` in app console

### BCX

1. Push changes to 37signals/emoji
2. Run `bundle update emoji` in app root

Notes
-----

Use `replace` for the sprite and `emojify` for individual images.

Todo
----

- Make all apps use lib/assets versions
- Move the sprite img/css into CF/BCX and remove from the gem
