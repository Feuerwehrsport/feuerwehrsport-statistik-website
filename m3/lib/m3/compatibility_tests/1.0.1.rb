# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.1...'
puts
puts '## The behaviour of value labels and hints is now the same as in SimpleForm.'
puts
puts "  f.value :foo, label: ''     # => empty, but space-using label"
puts '  f.value :foo, label: false  # => no label and no space used'
puts '  f.value :foo, label: nil    # => label falls back to human_attribute_name'
puts
puts "  f.value :foo, hint: ''      # => empty, but space-using hint"
puts '  f.value :foo, hint: false   # => no hint and no space used'
puts '  f.value :foo, hint: nil     # => hint falls back to t3'
puts
puts "Especially you should replace `label: '&nbsp;'.html_safe` with label: ''."
puts

controllers = Dir.glob(Rails.application.root.join('app', 'controllers', '**', '*.rb'))
value_labels = controllers.map do |path|
  matches = File.foreach(path).grep(/\.value.*(label|hint):/)
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
raise "Add `config.m3.compatible_version = '1.0.1'` to your application.rb after checking all hints above."
