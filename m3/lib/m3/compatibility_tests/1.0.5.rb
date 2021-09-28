# frozen_string_literal: true

puts '# Running M3 compatibility checks for version 1.0.5...'
puts
puts '## Dedicated M3::Login::VerificationsController'
puts
puts 'In routes.rb'
puts ' * Remove old verify action from session controller'
puts " * Add `get 'verify_login/:token', to: 'm3/login/verifications#verify', as: :verify_login`"
puts
puts 'In ability.rb'
puts ' * Remove verify from M3::Login::Session'
puts ' * Add `can(:verify, M3::Login::Base)`'
puts
puts 'Check translations for app-specific changes.'
puts

raise "Add `config.m3.compatible_version = '1.0.5'` to your application.rb after checking all hints above."
