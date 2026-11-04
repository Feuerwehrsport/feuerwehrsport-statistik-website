# frozen_string_literal: true

require 'rails_helper'

describe FederalState do
  it 'can be loaded, validates and orders by name' do
    federal_state = described_class.new
    expect(federal_state).not_to be_valid
    expect(federal_state.errors.attribute_names).to include(:name, :shortcut)

    described_class.create!(name: 'Sachsen', shortcut: 'SN')
    described_class.create!(name: 'Berlin', shortcut: 'BE')
    expect(described_class.pluck(:shortcut)).to eq %w[BE SN]
  end
end
