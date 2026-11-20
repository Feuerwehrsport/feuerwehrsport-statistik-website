# frozen_string_literal: true

# public/manifest.webmanifest (icons for home screens); Rack does not know the extension yet
Rack::Mime::MIME_TYPES['.webmanifest'] = 'application/manifest+json'

Mime::Type.register 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', :xlsx
