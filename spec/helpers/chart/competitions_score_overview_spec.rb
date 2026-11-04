# frozen_string_literal: true

require 'rails_helper'

describe Chart::CompetitionsScoreOverview do
  let(:chart) { described_class.new(competitions: competitions.map(&:decorate)) }
  let(:rendered_charts) { [] }
  let(:competitions) { [] }

  before do
    allow(chart).to receive(:high_chart).and_wrap_original do |method, id, high_chart|
      rendered_charts.push(high_chart)
      method.call(id, high_chart)
    end
  end

  def series_data
    rendered_charts.last.series_data.first[:data]
  end

  def competition_with(attributes)
    build(:competition, **attributes)
  end

  describe '#year_overview' do
    let(:competitions) do
      [
        competition_with(date: Date.parse('2017-05-01')),
        competition_with(date: Date.parse('2018-05-20')),
        competition_with(date: Date.parse('2018-01-20')),
      ]
    end

    it 'renders a column chart' do
      output = chart.year_overview
      expect(output).to include('Highcharts.Chart')
      expect(output).to match(/<div id="high-chart-\h{12}"/)
      expect(rendered_charts.last.options[:chart][:type]).to eq 'column'
      expect(rendered_charts.last.options[:xAxis][:categories]).to eq I18n.t('date.month_names_short')
    end

    it 'counts competitions per month' do
      chart.year_overview
      expect(series_data.pluck(:y)).to eq [1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0]
    end

    it 'names the months' do
      pending 'Bug: date.month_names starts with nil (rails_i18n), names are shifted by one month'
      chart.year_overview
      expect(series_data.pluck(:name).first(5)).to eq %w[Januar Februar März April Mai]
    end
  end

  describe '#week_overview' do
    let(:competitions) do
      [
        competition_with(date: Date.parse('2017-05-01')), # Monday
        competition_with(date: Date.parse('2017-05-07')), # Sunday
        competition_with(date: Date.parse('2017-05-14')), # Sunday
      ]
    end

    it 'counts competitions per weekday starting with monday' do
      chart.week_overview
      expect(series_data.pluck(:y)).to eq [1, 0, 0, 0, 0, 0, 2]
      expect(rendered_charts.last.options[:xAxis][:categories]).to eq I18n.t('date.day_names_short')
    end

    it 'names the weekdays' do
      pending 'Bug: date.day_names starts with Sonntag, index 7 is nil'
      chart.week_overview
      expect(series_data.pluck(:name)).to eq %w[Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag]
    end
  end

  describe '#disciplines_overview' do
    let(:competitions) do
      [
        competition_with(hb_male: 1, hl_female: 1, fs_male: 1, gs: 1),
        competition_with(hl_male: 3),
        competition_with(hb_female: 3),
        competition_with(hb_female: 3),
        competition_with(la_male: 2),
        competition_with(hb_male: 1, hl_male: 1),
        competition_with(gs: 1),
      ]
    end

    it 'groups competitions by offered disciplines' do
      chart.disciplines_overview
      expect(series_data).to eq [
        { name: 'Alle', y: 1 },
        { name: 'Nur HL', y: 1 },
        { name: 'Nur HB', y: 2 },
        { name: 'Nur LA', y: 1 },
        { name: 'HB und HL', y: 1 },
        { name: 'Andere', y: 1 },
      ]
    end

    context 'with only one kind' do
      let(:competitions) { [competition_with(la_female: 1)] }

      it 'skips empty groups' do
        chart.disciplines_overview
        expect(series_data).to eq [{ name: 'Nur LA', y: 1 }]
      end
    end
  end

  describe '#team_scores_overview' do
    let(:score_type) { create(:score_type) }
    let(:competitions) do
      [
        competition_with(score_type:),
        competition_with(score_type:),
        competition_with(score_type: nil),
      ]
    end

    it 'counts competitions per score type' do
      chart.team_scores_overview
      expect(series_data).to eq [{ name: '10/8/6', y: 2 }]
    end
  end

  describe '#teams_count_overview' do
    let(:competitions) do
      [0, 1, 10, 11, 20, 21, 30, 31].map { |count| competition_with(teams_count: count) }
    end

    it 'groups competitions by teams count' do
      chart.teams_count_overview
      expect(series_data).to eq [
        { name: 'Keine', y: 1 },
        { name: '1 bis 10', y: 2 },
        { name: '11 bis 20', y: 2 },
        { name: '21 bis 30', y: 2 },
        { name: '> 30', y: 1 },
      ]
    end
  end

  describe '#people_count_overview' do
    let(:competitions) do
      [0, 25, 26, 50, 51, 75, 76, 100, 101].map { |count| competition_with(people_count: count) }
    end

    it 'groups competitions by people count' do
      chart.people_count_overview
      expect(series_data.pluck(:y)).to eq [1, 1, 2, 2, 2, 1]
      expect(series_data.first[:name]).to eq 'Keine'
      expect(series_data.last[:name]).to eq '> 100'
    end

    context 'with only small competitions' do
      let(:competitions) { [competition_with(people_count: 3)] }

      it 'skips empty groups' do
        chart.people_count_overview
        expect(series_data).to eq [{ name: '1 bis 25', y: 1 }]
      end
    end
  end
end
