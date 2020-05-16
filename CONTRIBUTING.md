Contributions to this project are [released](https://help.github.com/articles/github-terms-of-service/#6-contributions-under-repository-license) to the public under the [project's open source license](LICENSE).

Some useful tools in development are:

```
script/bootstrap
```

Sets up the development environment. The prerequisites are:

* Ruby 1.9+
* Bundler

```
script/test
```

Runs the test suite.

```
script/console
```

Opens `irb` console with gemoji library preloded for experimentation.

```
script/release
```

For maintainers only: after the gemspec has been edited, this commits the
change, tags a release, and pushes it to both GitHub and RubyGems.org.
