# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calculation::Competition do
  let(:competition) { create(:competition) }
  let(:context) { instance_double(ActionView::Base, request: nil) }
  let(:calculation) { described_class.new(competition, context) }
  let(:hb_male) { create(:single_discipline, :hb_male) }
  let(:hl_male) { create(:single_discipline, :hl_male) }
  let(:hl_female) { create(:single_discipline, :hl_female) }
  let(:alfred) { create(:person) }
  let(:bernd) { create(:person, first_name: 'Bernd') }
  let(:johanna) { create(:person, :female) }
  let(:la) { create(:group_score_type) }
  let(:la_category) { create(:group_score_category, competition:, group_score_type: la) }

  before do
    create(:score, competition:, person: alfred, single_discipline: hb_male, time: 2000)
    create(:score, competition:, person: alfred, single_discipline: hb_male, time: 1900)
    create(:score, competition:, person: bernd, single_discipline: hb_male, time: 2100)
    create(:score, competition:, person: alfred, single_discipline: hb_male, time: 1800, team_number: -1)
    create(:score, competition:, person: alfred, single_discipline: hl_male, time: 1600)
    create(:score, competition:, person: johanna, single_discipline: hl_female, time: 1700)
    create(:group_score, group_score_category: la_category, time: 2400)
    create(:group_score, group_score_category: la_category, time: 2300)
    create(:group_score, group_score_category: la_category, time: 2600, gender: :female)
  end

  it 'generates disciplines with scores' do
    expect(calculation.disciplines.map { |d| [d.discipline.try(:id) || d.discipline, d.gender, d.category, d.count] })
      .to eq [
        [hl_male.id, :male, false, 1],
        [hl_female.id, :female, false, 1],
        [hb_male.id, :male, false, 2],
        [hb_male.id, :male, -1, 1],
        [:zk, :male, nil, 1],
        [:la, :female, la_category, 1],
        [:la, :male, la_category, 1],
      ]
  end

  it 'collects categories' do
    expect(calculation.single_categories).to eq(
      hl_male.id => Set[false],
      hl_female.id => Set[false],
      hb_male.id => Set[false, -1],
    )
    expect(calculation.group_categories.keys).to eq [:la]
    expect(calculation.group_categories[:la].map(&:object)).to eq [la_category]
    expect(calculation.single_score_count).to eq 5
  end

  it 'finds disciplines' do
    hb = calculation.discipline(hb_male, :male, false)
    expect(hb.scores.map(&:time)).to contain_exactly(1900, 2100)
    expect(hb.all_scores.count).to eq 3
    expect(hb).to be_any

    expect(calculation.discipline(:zk, :male, nil).scores.map(&:time)).to eq [3500]
    expect(calculation.discipline(:zk, :female, nil)).to be_nil
    expect(calculation.discipline(hb_male, :female, false)).to be_nil
  end

  it 'provides a chart per discipline' do
    chart = calculation.discipline(hb_male, :male, false).chart
    expect(chart).to be_a Chart::CompetitionDisciplineCategoryOverview
  end
end
