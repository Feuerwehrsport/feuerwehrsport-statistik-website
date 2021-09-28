# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.7...'
puts
puts '## The gem +paranoia+ is no longer a dependency. The migrations drop all deleted logins and remove '
puts '## the +deleted_at+ column.'
puts

files = Dir.glob(Rails.application.root.join('**', '*.rb'))
class_matches = files.map do |path|
  next if %w[/m3/ /tmp/].any? { |dir| path.include?(dir) }

  matches = File.foreach(path).grep(/(deleted_at)|(deleted)|(really_destroy)|(acts_as_paranoid)/)
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
raise "Add `config.m3.compatible_version = '1.0.7'` to your application.rb after checking all hints above."
