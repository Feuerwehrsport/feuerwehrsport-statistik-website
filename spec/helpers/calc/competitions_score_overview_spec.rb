# frozen_string_literal: true

require 'rails_helper'

describe Calc::CompetitionsScoreOverview do
  let(:nation) { create(:nation) }
  let(:alfred) { create(:person, nation:) }
  let(:bernd) { create(:person, first_name: 'Bernd', nation:) }
  let(:foreigner) { create(:person, first_name: 'Istvan', nation: create(:nation, :ungarn)) }
  let(:competition2017) { create(:competition) }
  let(:competition2018) { create(:competition, date: Date.parse('2018-05-01')) }
  let(:other_competition) { create(:competition, date: Date.parse('2018-06-01')) }
  let(:hb_male) { create(:single_discipline, :hb_male) }
  let(:la) { create(:group_score_type) }
  let(:team) { create(:team) }

  let(:overview) { described_class.new(competitions: [competition2017, competition2018]) }
  let!(:best2017) do
    create(:score, person: alfred, single_discipline: hb_male, competition: competition2017, time: 1900)
  end
  let!(:best2018) do
    create(:score, person: bernd, single_discipline: hb_male, competition: competition2018, time: 1800)
  end
  let!(:group_best) do
    category = create(:group_score_category, group_score_type: la, competition: competition2017)
    create(:group_score, team:, group_score_category: category, time: 2600)
    create(:group_score, team:, group_score_category: category, time: 2500)
  end

  before do
    create(:score, person: bernd, single_discipline: hb_male, competition: competition2017, time: 2000)
    create(:score, person: bernd, single_discipline: hb_male, competition: competition2017,
                   time: Firesport::INVALID_TIME)
    create(:score, person: foreigner, single_discipline: hb_male, competition: competition2017, time: 1500)
    create(:score, person: alfred, single_discipline: hb_male, competition: other_competition, time: 1000)
  end

  it 'collects the competition ids' do
    expect(overview.competition_ids).to eq [competition2017.id, competition2018.id]
  end

  it 'calculates the single discipline overview' do
    hb = overview.disciplines['hb'][:male]
    expect(hb.key).to eq 'hb'
    expect(hb.types.keys).to eq [hb_male.id.to_s]

    type = hb.types[hb_male.id.to_s]
    expect(type.type).to eq hb_male
    expect(type.count).to eq 4
    expect(type.average).to eq 1900
    expect(type.best.object).to eq best2018
    expect(type.years.transform_values { |scores| scores.map(&:object) }).to eq(
      2017 => [best2017],
      2018 => [best2018],
    )
  end

  it 'calculates the group discipline overview' do
    la_overview = overview.disciplines['la']['male']
    type = la_overview.types[la.id.to_s]
    expect(type.type).to eq la
    expect(type.count).to eq 2
    expect(type.average).to eq 2550
    expect(type.best.object).to eq group_best
    expect(type.years.transform_values { |scores| scores.map(&:object) }).to eq(2017 => [group_best])
  end

  it 'returns empty hash for competitions without scores' do
    expect(described_class.new(competitions: [create(:competition, date: Date.parse('2000-01-01'))]).disciplines)
      .to eq({})
  end
end
