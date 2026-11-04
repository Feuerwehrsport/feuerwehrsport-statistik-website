# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::SingleDisciplineOverview do
  let(:person) { create(:person) }
  let(:hb_male) { create(:single_discipline, :hb_male) }
  let(:hl_male) { create(:single_discipline, :hl_male) }
  let(:competition2017) { create(:competition) }
  let(:competition2016) { create(:competition, date: Date.parse('2016-05-01')) }

  before do
    create(:score, person:, single_discipline: hb_male, competition: competition2017, time: 2000)
    create(:score, person:, single_discipline: hb_male, competition: competition2017, time: 1900)
    create(:score, person:, single_discipline: hb_male, competition: competition2016, time: 2150)
    create(:score, person:, single_discipline: hb_male, competition: competition2016, time: Firesport::INVALID_TIME)
    create(:score, person: create(:person, first_name: 'Bernd'), single_discipline: hb_male, time: 1000)
    hl_male
  end

  it 'returns only disciplines with scores' do
    overviews = described_class.for(person)
    expect(overviews.map(&:single_discipline)).to eq [hb_male]
  end

  describe 'statistics' do
    let(:overview) { described_class.new(person, hb_male) }

    it 'calculates count, best and average' do
      expect(overview.count).to eq 4
      expect(overview.valid_scores.map(&:time)).to contain_exactly(2000, 1900, 2150)
      expect(overview.best_time).to eq '19,00'
      expect(overview.average_time).to eq '20,16'
      expect(overview.scores_decorated).to all(be_decorated)
    end

    it 'returns best valid score per competition sorted by date for chart' do
      expect(overview.chart_scores.map(&:time)).to eq [2150, 1900]
    end
  end

  describe 'without scores' do
    let(:overview) { described_class.new(person, hl_male) }

    it 'is blank' do
      expect(overview).to be_blank
      expect(overview.count).to eq 0
      expect(overview.best_time).to be_nil
      expect(overview.average_time).to eq 'D'
    end
  end
end
