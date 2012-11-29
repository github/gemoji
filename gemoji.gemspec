# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'gemoji'
  s.version = '1.2.1'
  s.summary = 'Emoji Assets'
  s.description = 'Emoji assets'

  s.authors  = ['GitHub']
  s.email    = 'support@github.com'
  s.homepage = 'https://github.com/github/gemoji'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
