require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
end

namespace :db do
  desc %(Generate Emoji data files needed for development)
  task :generate => [
    'db/Category-Emoji.json',
    'db/ucd.nounihan.grouped.xml',
    'db/emoji-test.txt',
  ]

  desc %(Dump a list of supported Emoji with Unicode descriptions and aliases)
  task :dump => :generate do
    system 'ruby', '-Ilib', 'db/dump.rb'
  end
end

task 'db/Category-Emoji.json' do |t|
  system 'plutil', '-convert', 'json', '-r',
    '/System/Library/Input Methods/CharacterPalette.app/Contents/Resources/Category-Emoji.plist',
    '-o', t.name
end

file 'db/ucd.nounihan.grouped.xml' do
  Dir.chdir('db') do
    system 'curl', '-fsSLO', 'http://www.unicode.org/Public/9.0.0/ucdxml/ucd.nounihan.grouped.zip'
    system 'unzip', '-q', 'ucd.nounihan.grouped.zip'
    rm 'ucd.nounihan.grouped.zip'
  end
end

file 'db/emoji-test.txt' do |t|
  system 'curl', '-fsSL', 'http://unicode.org/Public/emoji/4.0/emoji-test.txt', '-o', t.name
end

directory 'images/unicode' do
  require 'emoji/extractor'
  Emoji::Extractor.new(64, Emoji.images_path).extract!
end
