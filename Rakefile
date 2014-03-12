require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
end

namespace :db do
  desc %(Generate Emoji data files needed for development)
  task :generate => ['db/Category-Emoji.json']
end

emoji_plist = '/System/Library/Input Methods/CharacterPalette.app/Contents/Resources/Category-Emoji.plist'

task 'db/Category-Emoji.json' do |t|
  system "plutil -convert json -r '#{emoji_plist}' -o '#{t.name}'"
end
