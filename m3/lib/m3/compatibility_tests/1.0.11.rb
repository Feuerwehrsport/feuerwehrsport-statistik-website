# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.11...'
puts
puts '## Use custom set of Font Awesome'
puts
puts 'Add your configuration to application.sass, e.g.:'
puts
puts '@import m3/fontawesome/regular'
puts '@import m3/fontawesome/brands'
puts ''
puts '.fa'
puts '  @extend .far'
puts

raise "Add `config.m3.compatible_version = #{M3::VERSION}` to your application.rb after checking all hints above."
