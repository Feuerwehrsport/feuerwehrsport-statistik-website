# frozen_string_literal: true

require 'rails_helper'

describe Calc::BestOf do
  let(:nation) { create(:nation) }
  let(:alfred) { create(:person, nation:) }
  let(:bernd) { create(:person, first_name: 'Bernd', nation:) }
  let(:johanna) { create(:person, :female, nation:) }
  let(:foreigner) { create(:person, first_name: 'Istvan', nation: create(:nation, :ungarn)) }
  let(:competition) { create(:competition) }
  let(:competition2016) { create(:competition, date: Date.parse('2016-06-01')) }

  let(:hb_male) { create(:single_discipline, :hb_male) }
  let(:hb_female) { create(:single_discipline, :hb_female, default_for_male: false, default_for_female: true) }
  let(:hb_female_old) { create(:single_discipline, :hb_female_old) }

  def entry(disciplines, discipline, gender, year = nil)
    disciplines.find { |d| d[:discipline] == discipline && d[:gender] == gender && d[:year] == year }
  end

  it 'returns no disciplines without scores' do
    expect(described_class.new.disciplines).to eq []
  end

  context 'with single scores' do
    before do
      create(:score, person: alfred, single_discipline: hb_male, competition:, time: 2100)
      create(:score, person: alfred, single_discipline: hb_male, competition:, time: 1900)
      create(:score, person: bernd, single_discipline: hb_male, competition:, time: 2000)
      create(:score, person: foreigner, single_discipline: hb_male, competition:, time: 1500)
      create(:score, person: johanna, single_discipline: hb_female, competition:, time: 1800)
      create(:score, person: johanna, single_discipline: hb_female_old, competition: competition2016, time: 2200)
    end

    it 'returns the best score of each german person ordered by time' do
      disciplines = described_class.new.disciplines
      expect(disciplines.map { |d| d.values_at(:discipline, :gender, :year) }).to eq [
        [:hb, :female, nil],
        [:hb, :male, nil],
        [:hb, :female, 2016],
      ]

      male = entry(disciplines, :hb, :male)
      expect(male[:scores].map(&:time)).to eq [1900, 2000]
      expect(male[:scores].map(&:person_id)).to eq [alfred.id, bernd.id]
      expect(male[:scores]).to all(be_decorated)
    end

    it 'uses the old female discipline for 2016' do
      disciplines = described_class.new.disciplines
      expect(entry(disciplines, :hb, :female)[:scores].map(&:time)).to eq [1800]
      expect(entry(disciplines, :hb, :female, 2016)[:scores].map(&:time)).to eq [2200]
    end
  end

  context 'with group scores' do
    let(:la) { create(:group_score_type) }
    let(:la_irregular) { create(:group_score_type, name: 'Sonderwertung', regular: false) }
    let(:gs) { create(:group_score_type, discipline: 'gs', name: 'GS') }
    let(:warin) { create(:team) }
    let(:mv) { create(:team, :mv) }

    before do
      la_category = create(:group_score_category, group_score_type: la, competition:)
      irregular_category = create(:group_score_category, group_score_type: la_irregular, competition:)
      gs_category = create(:group_score_category, group_score_type: gs, competition:)

      create(:group_score, team: warin, group_score_category: la_category, time: 2500)
      create(:group_score, team: warin, group_score_category: la_category, time: 2400)
      create(:group_score, team: mv, group_score_category: la_category, time: 2300)
      create(:group_score, team: mv, group_score_category: irregular_category, time: 2000)
      create(:group_score, team: mv, group_score_category: gs_category, time: 3000, gender: :female)
    end

    it 'returns the best regular score of each team' do
      disciplines = described_class.new.disciplines
      expect(disciplines.map { |d| d.values_at(:discipline, :gender) }).to eq [%i[gs female], %i[la male]]

      expect(entry(disciplines, :la, :male)[:scores].map { |s| [s.team_id, s.time] }).to eq [
        [mv.id, 2300],
        [warin.id, 2400],
      ]
      expect(entry(disciplines, :gs, :female)[:scores].map(&:time)).to eq [3000]
    end
  end
end
