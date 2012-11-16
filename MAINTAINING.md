# Maintainers

## Releasing a new gem

If you are just adding new emoji or making a small fix, only increment the patch level "1.0.*x*". If you need to rename a ton of emojis or making any other radical (but still mostly backwards compatible changes), but the minor version "1.*x*.*x*".

### Make a release commit

To prepare the release commit, edit the [gemoji.gemspec](https://github.com/github/gemoji/blob/master/gemoji.gemspec) `version` value. Then make a single commit with the description as "Gemoji 1.x.x". Finally, tag the commit with `v1.x.x`.

Example commit https://github.com/github/gemoji/commit/v1.0.0

```
$ git ci -m "Emoji 1.0.0"
$ git tag v1.0.0
$ git push
$ git push --tags
```

### Publish the gem

Build and push the new gem with

```
$ gem build gemoji.gemspec
$ gem push gemoji-1.0.0.gem
```