# frozen_string_literal: true

# public/manifest.webmanifest (icons for home screens); Rack does not know the extension yet
Rack::Mime::MIME_TYPES['.webmanifest'] = 'application/manifest+json'
