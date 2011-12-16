Emoji
=====

Shared Emoji assets between GitHub and Campfire.

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

1. Update emoji version in config/externals.yml
2. Run `cap local externals:setup` in app root
3. Run `rake emoji` in app root
4. Test, commit, push, and deploy
