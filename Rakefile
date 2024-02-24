require 'rake/testtask'
require 'rake/extensiontask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
end

namespace :db do
  desc %(Generate Emoji data files needed for development)
  task :generate => [
    'vendor/unicode-emoji-test.txt',
  ]

  desc %(Dump a list of supported Emoji with Unicode descriptions and aliases)
  task :dump => :generate do
    system 'ruby', '-Ilib', 'db/dump.rb'
  end
end

file 'vendor/unicode-emoji-test.txt' do |t|
  system 'curl', '-fsSL', 'http://unicode.org/Public/emoji/15.0/emoji-test.txt', '-o', t.name
end

namespace :c do
  task :headers do
    require 'emoji/tables'
    gem_dir = File.dirname(File.realpath(__FILE__))

    File.open(File.join(gem_dir, "ext/gemoji/emoji.h"), "w") do |file|
      file.puts(Emoji::Tables.generate_length_tables)
    end
  end
end

Rake::ExtensionTask.new('gemoji')
