Gem::Specification.new do |s|
  s.name    = "emoji"
  s.version = "0.3.3"
  s.summary = "Emoji Assets"
  s.description = "Shared Emoji assets between GitHub,  Campfire, and BCX."

  s.authors  = ["GitHub", "37signals"]
  s.email    = "support@github.com"
  s.homepage = "https://github.com/github/emoji"

  s.files = `git ls-files`.split("\n")

  s.add_development_dependency "sprockets", "~> 2.0"
end
