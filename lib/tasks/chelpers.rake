require 'json'

desc "generate helpers for the C extension"
task :c_helpers do
  emoji_file = "#{Rake.original_dir}/db/emoji.json"
  emoji = JSON.parse(File.read(emoji_file))

  all_emojis = emoji.map { |e| e['emoji'] }.compact
  all_emojis.map! { |e| e.bytes }

  magic_bytes = Array(256) { 0 }
  all_emojis.each { |bytes| magic_bytes[bytes.first] = 1 }

  puts magic_bytes.inspect
end
