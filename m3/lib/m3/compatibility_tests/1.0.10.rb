# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.10...'
puts
puts '## Update Font-Awesome to version 5'
puts
puts 'https://fontawesome.com/how-to-use/on-the-web/setup/upgrading-from-version-4'
puts
puts 'Ensure that all usings of fa icons are still availible.'
puts

files = Dir.glob(Rails.root.join('**/*.rb'))
row_matches = files.map do |path|
  next if path.starts_with?(Rails.root.join('m3'))

  matches = File.foreach(path).grep(/fa-/)
  (["#{path}: "] + matches).join("\n  ") if matches.present?
end
row_matches.compact!
if row_matches.present?
  puts 'Please check:'
  puts
  row_matches.each { |label| puts label }
else
  puts 'Could not find conspicuous code parts.'
end

puts
raise "Add `config.m3.compatible_version = '1.0.10'` to your application.rb after checking all hints above."
