# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
# Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

# Dart Sass (dartsass-sprockets): our own stylesheets use @use (see _theme.scss), these deprecations come from the
# vendored Bootstrap 5.3 and Font Awesome 5, which only work with @import (module support: Bootstrap 6). quiet_deps
# does not help here, the sprockets importer marks all files as dependencies, so it would hide our own warnings too.
# spec/lint/stylesheets_spec.rb keeps @import out of our own files.
Rails.application.config.sass.silence_deprecations = %w[import global-builtin color-functions slash-div if-function]
