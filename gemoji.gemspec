Gem::Specification.new do |s|
  s.name    = "gemoji"
  s.version = "4.0.0.rc3"
  s.summary = "Unicode emoji library"
  s.description = "Character information and metadata for Unicode emoji."

  s.required_ruby_version = '> 1.9'

  s.authors  = ["GitHub"]
  s.email    = "support@github.com"
  s.homepage = "https://github.com/github/gemoji"
  s.licenses = ["MIT"]

  s.files = Dir[
    "README.md",
    "LICENSE",
    "db/emoji.json",
    "lib/**/*.rb",
  ]
end
