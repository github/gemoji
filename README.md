Emoji
=====

Shared Emoji assets between GitHub, Campfire, and BCX.

Contributing
------------

### Designers

Drop a 64x64 png into `images/` and commit it.

Deploying
---------

### GitHub

1. Update `emoji` gem in Gemfile
1. Rerun `rake emoji` in app root

### Campfire

1. Push changes to 37signals/emoji
2. Update emoji version in config/externals.yml
3. Run `cap local externals:setup` in app root
4. Run `rake emoji` in app root
5. Run `Rails.cache.clear` in app console

### BCX

1. Push changes to 37signals/emoji
2. Run `bundle update emoji` in app root

Todo
----

- Figure out what's wrong with the symlinks removed in 97709f
