# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDuplicates do
  describe '.name_key' do
    it 'normalizes prefixes, suffixes, umlauts and abbreviations' do
      expect(described_class.name_key('FF Bürgel M')).to eq 'buergel'
      expect(described_class.name_key('Freiwillige Feuerwehr Warin II')).to eq 'warin'
      expect(described_class.name_key('FfW Groß-Laasch')).to eq 'grosslaasch'
      expect(described_class.name_key('Gr. Laasch')).to eq 'grosslaasch'
      expect(described_class.name_key('Team Leo Schulze')).to eq 'leoschulze'
    end
  end

  describe '#candidates' do
    let!(:team) { create(:team, name: 'FF Warin M', shortcut: 'Warin M', state: nil, checked_at: nil) }
    let!(:same) { create(:team, name: 'Feuerwehr Warin', shortcut: 'Warin') }
    let!(:contained) { create(:team, name: 'FF Warin-Mustin', shortcut: 'Warin-Mustin') }
    let!(:typo) { create(:team, name: 'FF Wahrin', shortcut: 'Wahrin') }
    let!(:spelled) { create(:team, name: 'FF Kuhs', shortcut: 'Kuhs') }
    let!(:shared) { create(:team, name: 'FF Anders', shortcut: 'Anders') }

    before do
      create(:team, name: 'FF Bützow', shortcut: 'Bützow')
      create(:team_spelling, team: spelled, name: 'FF Warin I', shortcut: 'Warin I')
      person = create(:person)
      create(:score, team:, person:)
      create(:score, team: shared, person:)
    end

    it 'ranks teams by shared people and names' do
      candidates = described_class.new(team).candidates
      expect(candidates.map(&:team)).to eq [shared, spelled, same, contained, typo]
      expect(candidates.map(&:reasons)).to eq [
        ['1 gemeinsame Person'],
        ['gleicher Name (Schreibweise „FF Warin I“)'],
        ['gleicher Name'],
        ['Name enthalten'],
        ['ähnlicher Name'],
      ]
    end
  end

  describe 'distance to the competition places' do
    let(:place) { create(:place, name: 'Warin', latitude: 53.8, longitude: 11.7) }
    let(:competition) { create(:competition, place:) }
    let!(:team) { create(:team, name: 'FF Neuendorf', shortcut: 'Neuendorf', state: nil, checked_at: nil) }
    let!(:far) { create(:team, name: 'FF Neuendorf', shortcut: 'Neuendorf', latitude: 50.9, longitude: 13.3) }
    let!(:near) { create(:team, name: 'FF Neuendorf', shortcut: 'Neuendorf', latitude: 53.7, longitude: 11.6) }
    let!(:unknown) { create(:team, :without_geo_location, name: 'FF Neuendorf', shortcut: 'Neuendorf') }

    before { create(:score, team:, competition:) }

    it 'prefers teams near the competition places' do
      candidates = described_class.new(team).candidates
      expect(candidates.map(&:team)).to eq [near, unknown, far]
      expect(candidates.map(&:reasons)).to eq [
        ['gleicher Name', 'ca. 13 km von Warin'],
        ['gleicher Name'],
        ['gleicher Name', 'ca. 340 km von Warin'],
      ]
      expect(described_class.new(team).competition_places).to eq [place]
    end
  end
end
