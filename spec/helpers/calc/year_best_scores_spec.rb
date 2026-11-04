# frozen_string_literal: true

require 'rails_helper'

describe Calc::YearBestScores do
  let(:nation) { create(:nation) }
  let(:alfred) { create(:person, nation:) }
  let(:bernd) { create(:person, first_name: 'Bernd', nation:) }
  let(:foreigner) { create(:person, first_name: 'Istvan', nation: create(:nation, :ungarn)) }
  let(:competition2017) { create(:competition) }
  let(:competition2018) { create(:competition, date: Date.parse('2018-05-01')) }
  let(:hl_male) { create(:single_discipline, :hl_male) }
  let(:la) { create(:group_score_type) }

  before do
    create(:score, person: alfred, single_discipline: hl_male, competition: competition2017, time: 1700)
    create(:score, person: alfred, single_discipline: hl_male, competition: competition2017, time: 1600)
    create(:score, person: alfred, single_discipline: hl_male, competition: competition2018, time: 1500)
    create(:score, person: bernd, single_discipline: hl_male, competition: competition2017, time: 1650)
    create(:score, person: foreigner, single_discipline: hl_male, competition: competition2017, time: 1400)

    category2017 = create(:group_score_category, group_score_type: la, competition: competition2017)
    create(:group_score, team: create(:team), group_score_category: category2017, time: 2400)
  end

  it 'returns the best german score per person of the given year' do
    disciplines = described_class.new(year: '2017').disciplines
    expect(disciplines.map { |d| d.values_at(:discipline, :gender) }).to eq [%i[hl male], %i[la male]]

    hl = disciplines.first[:scores]
    expect(hl.map { |s| [s.person_id, s.time] }).to eq [[alfred.id, 1600], [bernd.id, 1650]]
    expect(hl).to all(be_decorated)
    expect(disciplines.last[:scores].map(&:time)).to eq [2400]
  end

  it 'only uses scores of the given year' do
    disciplines = described_class.new(year: 2018).disciplines
    expect(disciplines.map { |d| d.values_at(:discipline, :gender) }).to eq [%i[hl male]]
    expect(disciplines.first[:scores].map(&:time)).to eq [1500]
  end

  it 'returns nothing for a year without scores' do
    expect(described_class.new(year: 2010).disciplines).to eq []
  end
end
