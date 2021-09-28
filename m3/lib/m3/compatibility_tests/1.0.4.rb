# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.4...'
puts
puts '## New index table headers.'
puts
puts 'The partial m3/app/views/application/_index_table_thead.html.haml now uses'
puts 'M3 application helpers index_label and sortable_index_labels. Some CSS classes'
puts 'like .sort-button or th.is-sorted have been removed. Please make sure existing'
puts 'index tables look still fine.'
puts

files = Dir.glob(Rails.application.root.join('**', '*.{haml,erb,html,css,sass,scss,rb}'))
class_matches = files.map do |path|
  next if %w[m3 public private log tmp].any? { |dir| path.start_with?(Rails.application.root.join(dir).to_s) }

  matches = File.foreach(path).grep(/sort-button/)
  matches += File.foreach(path).grep(/is-sorted/)
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
raise "Add `config.m3.compatible_version = '1.0.4'` to your application.rb after checking all hints above."
