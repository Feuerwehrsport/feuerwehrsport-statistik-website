# frozen_string_literal: true

# ES modules (app/javascript). jQuery, Bootstrap and DataTables are classic scripts (layouts/_head).
pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'chart.js', to: 'chart.umd.min.js' # Chart.js 4.6.1 (MIT), vendored
pin 'trix', to: 'trix.esm.min.js' # Trix 2.1.19 (MIT), vendored; loaded by trix_controller only
