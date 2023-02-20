# frozen_string_literal: true

SimpleCov.start do
  track_files '{app,lib}/**/*.rb'

  add_filter '/spec/'
  add_filter '/m3/'
  add_filter '/m3_rspec/'
  add_filter '/firesport/'
  add_filter '/firesport-series/'
end
