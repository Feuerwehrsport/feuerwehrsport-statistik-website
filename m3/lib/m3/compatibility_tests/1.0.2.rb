# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.2...'
puts
puts '## The form structure method +row+ has been removed.'
puts

controllers = Dir.glob(Rails.application.root.join('app', 'controllers', '**', '*.rb'))
row_matches = controllers.map do |path|
  matches = File.foreach(path).grep(/\.row[^a-z_]/)
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
puts '## The class +M3::Form::Structure::Builder+ has been removed. Use +M3::Form::Structure+ instead.'
puts

files = Dir.glob(Rails.application.root.join('**', '*.rb'))
class_matches = files.map do |path|
  next if %w[/m3/ /tmp/].any? { |dir| path.include?(dir) }

  matches = File.foreach(path).grep(/M3::Form::Structure::Builder/)
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
raise "Add `config.m3.compatible_version = '1.0.2'` to your application.rb after checking all hints above."
