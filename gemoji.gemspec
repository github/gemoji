Gem::Specification.new do |s|
  s.name    = "gemoji"
  s.version = "3.0.0"
  s.summary = "Emoji library"
  s.description = "Character information and metadata for standard and custom emoji."
  s.executables = ["gemoji"]

  s.required_ruby_version = '> 1.9'

  s.authors  = ["GitHub"]
  s.email    = "support@github.com"
  s.homepage = "https://github.com/github/gemoji"
  s.licenses = ["MIT"]

  s.files = Dir[
    "README.md",
    "bin/gemoji",
    "images/*.png",
    "db/Category-Emoji.json",
    "db/emoji.json",
    "lib/**/*.rb",
  ]
end
