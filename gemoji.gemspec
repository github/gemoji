Gem::Specification.new do |s|
  s.name        = "gemoji"
  s.version     = "1.1.2"
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Emoji Assets"
  s.description = "Emoji assets"

  s.authors  = ["GitHub"]
  s.email    = "support@github.com"
  s.homepage = "https://github.com/github/gemoji"

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'

  s.add_dependency "railties", ">= 3.0", "< 5.0"
end
