# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::DoubleEventDisciplineOverview do
  let(:person) { create(:person) }
  let(:hb_male) { create(:single_discipline, :hb_male) }
  let(:hl_male) { create(:single_discipline, :hl_male) }
  let(:hl_female) { create(:single_discipline, :hl_female) }
  let(:competition2017) { create(:competition) }
  let(:competition2016) { create(:competition, date: Date.parse('2016-05-01')) }
  let(:competition2015) { create(:competition, date: Date.parse('2015-05-01')) }

  def double_event(competition, hb_time, hl_time, hl_discipline = hl_male)
    create(:score, person:, competition:, single_discipline: hb_male, time: hb_time)
    create(:score, person:, competition:, single_discipline: hl_discipline, time: hl_time)
  end

  it 'returns empty list without double events' do
    create(:score, person:, single_discipline: hb_male)
    expect(described_class.for(person)).to eq []
  end

  context 'with double events' do
    before do
      double_event(competition2017, 1900, 1700)
      double_event(competition2016, 2000, 1560)
      double_event(competition2015, 2100, 1500, hl_female)
    end

    it 'groups double events by disciplines' do
      overviews = described_class.for(person)
      expect(overviews.map { |o| [o.hb_id, o.hl_id, o.count] }).to eq [
        [hb_male.id, hl_male.id, 2],
        [hb_male.id, hl_female.id, 1],
      ]
    end

    it 'calculates statistics' do
      overview = described_class.for(person).first
      expect(overview.person).to eq person
      expect(overview.best_time).to eq '35,60'
      expect(overview.average_time).to eq '35,80'
      expect(overview.valid_scores.map(&:time)).to contain_exactly(3600, 3560)
      expect(overview.chart_scores.map(&:hb)).to eq [2000, 1900]
      expect(overview.scores_decorated).to all(be_decorated)
    end
  end
end
