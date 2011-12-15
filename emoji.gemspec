Gem::Specification.new do |s|
  s.name    = "emoji"
  s.version = "0.1"
  s.summary = "Emoji Assets"
  s.description = "Emoji used on GitHub and Campfire"

  s.authors  = ["GitHub", "37signals"]
  s.email    = "support@github.com"
  s.homepage = "https://github.com/github/emoji"

  s.files = `git ls-files`.split("\n")

  s.add_development_dependency "sprockets", "~> 2.0"
end
