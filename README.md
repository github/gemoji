Emoji
=====

Shared Emoji assets between GitHub,  Campfire, and BCX.

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

1. Push changes to 37signals/emoji repo
2. Update emoji version in config/externals.yml
3. Run `cap local externals:setup` in app root
4. Run `rake emoji` in app root
5. Test locally after running `Rails.cache.clear`
6. Commit, push, deploy

### BCX

1. Run `bundle update emoji` in app root
