# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.9...'
puts
puts '## Create/Update: Authorize valid records only'
puts
puts 'Ensure that all M3 models implement #valid? rather than returning a boolean for #save.'
puts 'This can be a problem in M3::FormObjects especially.'
puts

files = Dir.glob(Rails.application.root.join('**', '*.rb'))
class_matches = files.map do |path|
  next if %w[/m3/ /tmp/].any? { |dir| path.include?(dir) }

  matches = File.foreach(path).grep(/M3::FormObject/)
  (["#{path}: "] + matches).join("\n  ") if matches.present?
end
class_matches.compact!
if class_matches.present?
  puts 'Please check:'
  puts
  class_matches.each { |label| puts label }
else
  puts 'Could not find conspicuous code parts.'
end

puts
raise "Add `config.m3.compatible_version = '1.0.9'` to your application.rb after checking all hints above."
