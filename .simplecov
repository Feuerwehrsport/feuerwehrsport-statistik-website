# frozen_string_literal: true

# configuration only, SimpleCov.start is called in spec/rails_helper.rb
SimpleCov.configure do
  cover '{app,lib}/**/*.rb'
  skip '/spec/'
  skip '/m3/'
end
