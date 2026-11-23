# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlaceDuplicates do
  describe '.name_key' do
    it 'normalizes umlauts, abbreviations and separators' do
      expect(described_class.name_key('Groß-Laasch')).to eq 'grosslaasch'
      expect(described_class.name_key('Gr. Laasch')).to eq 'grosslaasch'
      expect(described_class.name_key('Cottbus OT Merzdorf')).to eq 'cottbusmerzdorf'
    end
  end

  describe '#candidates' do
    let(:place) { create(:place, name: 'Cottbus Merzdorf') }
    let!(:near) { create(:place, name: 'Merzdorf', latitude: 51.8, longitude: 14.4) }
    let!(:far) { create(:place, name: 'Cottbus', latitude: 54.1, longitude: 11.9) }
    let!(:typo) { create(:place, name: 'Merzdorff') }

    before do
      create(:place, name: 'Merz')
      create(:place, name: 'Anderswo')
      team = create(:team, latitude: 51.78, longitude: 14.33)
      create(:score, team:, competition: create(:competition, place:))
    end

    it 'ranks places by name and the distance to the teams' do
      duplicates = described_class.new(place)
      expect(duplicates.estimated_latlon).to eq [51.78, 14.33]
      expect(duplicates.candidates.map(&:place)).to eq [near, far]
      expect(duplicates.candidates.map(&:reasons)).to eq [
        ['Name enthalten', 'ca. 5 km von den Mannschaften'],
        ['Name enthalten', 'ca. 305 km von den Mannschaften'],
      ]
      expect(described_class.new(near).candidates.map(&:place)).to include(typo)
    end
  end
end
