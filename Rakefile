require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
end

namespace :db do
  task :generate do
    system "cp /System/Library/Input\\ Methods/CharacterPalette.app/Contents/Resources/Category-Emoji.plist db/"
    system "plutil -convert json db/Category-Emoji.plist"
    system "mv db/Category-Emoji.plist db/Category-Emoji.json"
  end
end
