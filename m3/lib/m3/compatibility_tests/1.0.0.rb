# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.0...'
puts

titles = I18n.translate('t3', locale: :de).values.map { |v| v[:views] && v[:views][:title] }
titles += I18n.translate('t3', locale: :en).values.map { |v| v[:views] && v[:views][:title] }
titles = titles.compact.select { |title| title.include?('%{') }

if titles.present?
  puts '## Ensure that interpolations for the following translations still work:'
  puts
  titles.each do |title|
    puts title
  end
  puts
  puts 'M3::ApplicationHelper#ca_title does not set a %{name} automatically anymore.' # rubocop:disable Style/FormatStringToken
  puts 'Check ControllerTranslations#t3_interpolations for workarounds.'
  puts
end

if Rails.configuration.m3.compatible_version.nil?
  puts '## Add the latest compatible version of M3 to your application.rb:'
  puts
  puts "  config.m3.compatible_version = '1.0.0'"
  puts
  puts 'Set the current version *after* you made sure that all compatibility tests are green.'
  puts
end

raise "Add `config.m3.compatible_version = #{M3::VERSION}` to your application.rb after checking all hints above."
