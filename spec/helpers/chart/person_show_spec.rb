# frozen_string_literal: true

require 'rails_helper'

describe Chart::PersonShow do
  let(:person) { create(:person) }
  let(:team_structs) { [] }
  let(:chart) { described_class.new(person:, team_structs:) }
  let(:rendered_charts) { [] }
  let(:hl_male) { create(:single_discipline, :hl_male) }
  let(:hb_male) { create(:single_discipline, :hb_male) }

  before do
    allow(chart).to receive(:render_chart).and_wrap_original do |method, **config|
      rendered_charts.push(config)
      method.call(**config)
    end
  end

  def config
    rendered_charts.last
  end

  def datasets
    config[:data][:datasets]
  end

  def score_in(year, time, single_discipline)
    competition = create(:competition, date: Date.new(year, 5, 1))
    create(:score, person:, competition:, time:, single_discipline:)
  end

  describe '#year_overview' do
    it 'returns empty string without valid scores' do
      score_in(2017, Firesport::INVALID_TIME, hb_male)
      expect(chart.year_overview).to eq ''
      expect(rendered_charts).to be_empty
    end

    it 'shows averages per year and discipline including empty years' do
      score_in(2015, 1900, hb_male)
      score_in(2015, 2000, hb_male)
      score_in(2015, Firesport::INVALID_TIME, hb_male)
      score_in(2017, 1555, hl_male)

      output = chart.year_overview
      expect(output).to include('data-controller="chart"')
      expect(config[:data][:labels]).to eq [2015, 2016, 2017]
      expect(config[:format]).to eq 'seconds'
      expect(datasets.map { |s| [s[:label], s[:data], s[:borderColor]] }).to eq [
        ['Hakenleitersteigen', [nil, nil, 15.55], '#B91C1C'],
        ['100m-Hindernisbahn', [19.5, nil, nil], '#1D4ED8'],
      ]
    end
  end

  describe '#discipline_invalid' do
    it 'counts valid and invalid scores' do
      scores = [1900, 2000, Firesport::INVALID_TIME].map { |time| build(:score, time:) }
      chart.discipline_invalid('Hindernisbahn', scores)
      expect(datasets.first[:label]).to eq 'Hindernisbahn'
      expect(config[:data][:labels]).to eq %w[Gültig Ungültig]
      expect(datasets.first[:data]).to eq [2, 1]
      expect(datasets.first[:backgroundColor]).to eq [Chart::Base::VALID_COLOR, Chart::Base::INVALID_COLOR]
    end
  end

  describe '#discipline_scores' do
    it 'shows times of single discipline' do
      scores = [score_in(2015, 1900, hb_male), score_in(2016, 2050, hb_male)].map(&:decorate)
      chart.discipline_scores(:hb, scores)
      expect(datasets.map { |s| [s[:label], s[:data]] }).to eq [['Zeit', [19.0, 20.5]]]
      expect(config[:data][:labels]).to eq ['01.05.2015', '01.05.2016']
    end

    it 'shows hb and hl times for double event' do
      competition = create(:competition)
      create(:score, person:, competition:, time: 1900, single_discipline: hb_male)
      create(:score, person:, competition:, time: 1600, single_discipline: hl_male)
      scores = ScoreDoubleEvent.where(person:).decorate
      chart.discipline_scores(:zk, scores)
      expect(datasets.map { |s| [s[:label], s[:data]] }).to eq [
        ['Zeit', [35.0]],
        ['HB', [19.0]],
        ['HL', [16.0]],
      ]
    end
  end

  describe '#discipline_positions' do
    let(:la_category) { create(:group_score_category) }

    it 'counts runs per position' do
      [1, 1, 3].each do |position|
        group_score = create(:group_score, group_score_category: la_category)
        create(:person_participation, person:, group_score:, position:)
      end

      chart.discipline_positions(:la)
      expect(datasets.first[:label]).to eq 'Läufe'
      expect(config[:data][:labels].zip(datasets.first[:data])).to contain_exactly(['Maschinist', 2], ['Saugkorb', 1])
    end

    context 'with female person in fs' do
      let(:person) { create(:person, :female) }
      let(:fs_category) do
        create(:group_score_category, group_score_type: create(:group_score_type, discipline: 'fs', name: 'FS'))
      end

      it 'uses gender specific position names' do
        group_score = create(:group_score, group_score_category: fs_category, gender: :female)
        create(:person_participation, person:, group_score:, position: 2)

        chart.discipline_positions(:fs)
        expect(config[:data][:labels]).to eq ['Hürde']
        expect(datasets.first[:data]).to eq [1]
      end
    end
  end

  describe '#team_scores_count' do
    let(:team_structs) do
      [
        { hb: 4, hl: 0, gs: 0, fs: 0, la: 2 },
        { hb: 1, hl: 7, gs: 0, fs: 0, la: 0 },
      ]
    end

    it 'shows counts per discipline scaled to max of all teams' do
      chart.team_scores_count(team_structs.first)
      expect(datasets.first[:data]).to eq [4, 2]
      expect(datasets.first[:backgroundColor]).to eq ['#1D4ED8', '#EA580C']
      expect(config[:options][:scales][:x][:max]).to eq 7
      expect(config[:data][:labels]).to eq ['Hindernisbahn', 'Löschangriff nass']
    end
  end
end
