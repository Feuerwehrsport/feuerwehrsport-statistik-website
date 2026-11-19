# frozen_string_literal: true

require 'rails_helper'

# The Sass deprecation warnings are silenced for _theme.scss (config/initializers/assets.rb),
# so this spec makes sure our own stylesheets stay on the module system.
describe 'stylesheets' do # rubocop:disable RSpec/DescribeClass
  # only these files may load the vendored libraries, which do not support @use yet
  let(:import_allowed) { %w[_theme.scss] }
  let(:own_stylesheets) do
    Rails.root.glob('app/assets/stylesheets/*.{scss,sass}').reject { |path| path.basename.to_s.in?(import_allowed) }
  end

  it 'uses @use instead of @import' do
    offenders = own_stylesheets.select { |path| path.read.match?(/^\s*@import\b/) }
    expect(offenders.map { |path| path.basename.to_s }).to be_empty
  end

  it 'does not use global built-in functions' do
    pattern = /\b(darken|lighten|mix|map-get|map-merge|percentage|unquote|nth|transparentize|opacify)\(/
    offenders = own_stylesheets.select { |path| path.read.match?(pattern) }
    expect(offenders.map { |path| path.basename.to_s }).to be_empty
  end

  it 'does not use the Sprockets helpers (Propshaft rewrites plain url() with the digest)' do
    offenders = own_stylesheets.select { |path| path.read.match?(/\b(asset|image|font)[-_](url|path)\(/) }
    expect(offenders.map { |path| path.basename.to_s }).to be_empty
  end
end
