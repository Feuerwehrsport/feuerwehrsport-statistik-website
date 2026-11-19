# frozen_string_literal: true

# Pages need the CSS of dartsass-rails (app/assets/builds). Build it once before the suite when a Sass source is newer.
RSpec.configure do |config|
  config.before(:suite) do
    builds = Rails.root.glob('app/assets/builds/*.css')
    sources = Rails.root.glob('{app,vendor}/assets/stylesheets/**/*.{scss,sass}')
    next if builds.size == Rails.application.config.dartsass.builds.size &&
            sources.map(&:mtime).max <= builds.map(&:mtime).min

    system('bin/rails', 'dartsass:build', exception: true)
  end
end
