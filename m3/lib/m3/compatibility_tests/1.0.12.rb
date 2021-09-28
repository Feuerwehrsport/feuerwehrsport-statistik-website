# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.12'
puts
puts '## The gem `validates_email_format_of` was replaced by `valid_email2`'
puts '## Replace `email_format: true` with `"valid_email_2/email": true`'
puts

files = Dir.glob(Rails.root.join('**/*.rb'))
value_labels = files.map do |path|
  next if path.ends_with?('compatibility_tests/1.0.12.rb')

  matches = File.foreach(path).grep(/email_format:/)
  (["#{path}: "] + matches).join("\n  ") if matches.present?
end
value_labels.compact!
if value_labels.present?
  puts 'Please check:'
  puts
  value_labels.each { |label| puts label }
else
  puts 'Could not find conspicuous code parts.'
end

puts
raise "Add `config.m3.compatible_version = '1.0.12'` to your application.rb after checking all hints above."
