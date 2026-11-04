# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Years::Inprovement do
  let(:hl_male) { create(:single_discipline, :hl_male) }
  let(:alfred) { create(:person) }
  let(:bernd) { create(:person, first_name: 'Bernd') }
  let(:carl) { create(:person, first_name: 'Carl') }
  let(:team) { create(:team) }
  let(:other_team) { create(:team, :mv) }

  def add_scores(person, year, times, team: self.team)
    competition = create(:competition, date: Date.new(year, 6, 1))
    times.each do |time|
      create(:score, person:, competition:, time:, single_discipline: hl_male, team:)
    end
  end

  before do
    add_scores(alfred, 2017, [2000, 2100, 2200, Firesport::INVALID_TIME])
    add_scores(alfred, 2018, [1800, 1900, 2000, 2500, Firesport::INVALID_TIME])
    add_scores(bernd, 2017, [2000, 2000, 2000], team: other_team)
    add_scores(bernd, 2018, [1950, 1950, 1950], team: other_team)
    add_scores(carl, 2017, [2000, 2000, 2000])
    add_scores(carl, 2018, [1500, 1500, Firesport::INVALID_TIME])
  end

  it 'has the previous year' do
    expect(described_class.new(2018).last_year).to eq 2017
  end

  it 'finds people with enough valid scores in both years' do
    inprovement = described_class.new(2018, hl_male, :male)
    expect(inprovement.person_ids).to contain_exactly(alfred.id, bernd.id)
    expect(inprovement).not_to be_blank
  end

  it 'is blank for other gender' do
    expect(described_class.new(2018, hl_male, :female)).to be_blank
  end

  it 'filters by team' do
    expect(described_class.new(2018, hl_male, :male, team).person_ids).to eq [alfred.id]
  end

  it 'returns items sorted by inprovement' do
    items = described_class.new(2018, hl_male, :male).all
    expect(items.map(&:person)).to eq [alfred, bernd]
    expect(items.map(&:difference)).to eq [200, 50]
    expect(items.first.current_scores.size).to eq 5
    expect(items.first.last_scores.size).to eq 4
    expect(items.first.year).to eq 2018
  end

  context 'with 2021 compared to 2020' do
    before do
      add_scores(carl, 2020, [2000, 2100])
      add_scores(carl, 2021, [1800, 1900, 2000])
      add_scores(bernd, 2020, [2000])
      add_scores(bernd, 2021, [1800, 1900, 2000])
    end

    it 'only needs two scores in 2020' do
      items = described_class.new(2021, hl_male, :male).all
      expect(items.map(&:person)).to eq [carl]
      expect(items.first.difference).to eq 2050 - 1900
    end
  end
end
