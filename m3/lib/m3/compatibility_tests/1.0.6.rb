# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.6...'
puts
puts '## The class +M3::Index::Structure::Builder+ has been removed. Use +M3::Index::Structure+ instead.'
puts

files = Dir.glob(Rails.application.root.join('**', '*.rb'))
class_matches = files.map do |path|
  next if %w[/m3/ /tmp/].any? { |dir| path.include?(dir) }

  matches = File.foreach(path).grep(/M3::Index::Structure::Builder/)
  (["#{path}: "] + matches).join("\n  ") if matches.present?
end
class_matches.compact!
if class_matches.present?
  puts 'Please check:'
  puts
  class_matches.each { |label| puts label }
  puts 'Change it to `M3::Index::Structure.build(options, &block).decorate`'
else
  puts 'Could not find conspicuous code parts.'
end

puts
raise "Add `config.m3.compatible_version = '1.0.6'` to your application.rb after checking all hints above."
