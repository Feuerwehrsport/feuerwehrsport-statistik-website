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
end
