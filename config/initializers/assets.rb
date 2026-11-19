# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Propshaft serves everything below app/assets/* and vendor/assets/* with a digest. Sources that are only read at
# build or run time stay private: Sass sources (built by dartsass-rails), the icon SVGs (inlined by UiHelper#icon)
# and the TTF fonts of the PDF exports (PrawnSupport).
Rails.application.config.assets.excluded_paths += %w[
  app/assets/stylesheets vendor/assets/stylesheets vendor/assets/icons app/assets/fonts
].map { |path| Rails.root.join(path) }

# Dart Sass (dartsass-rails): app/assets/stylesheets/*.sass → app/assets/builds/*.css
Rails.application.config.dartsass.builds = { 'frontend.sass' => 'frontend.css', 'backend.sass' => 'backend.css' }
# Our own stylesheets use @use (see _theme.scss), only _theme.scss still @imports the vendored Bootstrap 5.3 (module
# support: Bootstrap 6), so the import deprecation is silenced. --quiet-deps hides the warnings inside the vendored
# libraries (loaded via load path); warnings of our own files are still shown.
# spec/lint/stylesheets_spec.rb keeps @import out of our own files.
Rails.application.config.dartsass.build_options += %w[
  --load-path=vendor/assets/stylesheets --quiet-deps --silence-deprecation=import
]
