# frozen_string_literal: true

require 'rails_helper'

describe Chart::TeamShow do
  let(:team) { create(:team) }
  let(:chart) { described_class.new(team:) }
  let(:rendered_charts) { [] }

  before do
    allow(chart).to receive(:high_chart).and_wrap_original do |method, id, high_chart|
      rendered_charts.push(high_chart)
      method.call(id, high_chart)
    end
  end

  def series
    rendered_charts.last.series_data
  end

  describe '#gender_pie' do
    before do
      create(:score, team:, person: create(:person))
      create(:score, team:, person: create(:person, first_name: 'Bernd'))
      create(:score, team:, person: create(:person, :female))
    end

    it 'counts members per gender' do
      output = chart.gender_pie
      expect(output).to include('Highcharts.Chart')
      expect(rendered_charts.last.options[:chart]).to include(type: 'pie', height: 150)
      expect(series.first[:name]).to eq 'Geschlecht'
      expect(series.first[:data].map { |d| d.slice(:name, :y) }).to contain_exactly(
        { name: I18n.t('gender.male'), y: 2 },
        { name: I18n.t('gender.female'), y: 1 },
      )
    end

    it 'colors the gender slices' do
      pending 'Bug: group(:gender).count returns string keys, GenderNames#gender_color only knows symbols'
      chart.gender_pie
      expect(series.first[:data]).to contain_exactly(
        { name: I18n.t('gender.male'), y: 2, color: '#97E6FE' },
        { name: I18n.t('gender.female'), y: 1, color: '#FEAE97' },
      )
    end
  end

  describe '#group_discipline_scores' do
    it 'shows times sorted by competition date' do
      later = create(:group_score_category, competition: create(:competition, date: Date.parse('2018-05-01')))
      earlier = create(:group_score_category, competition: create(:competition, date: Date.parse('2016-05-01')))
      scores = [
        create(:group_score, team:, group_score_category: later, time: 2500),
        create(:group_score, team:, group_score_category: earlier, time: 2210),
      ].map(&:decorate)

      chart.group_discipline_scores(scores)
      expect(series.map { |s| [s[:name], s[:data]] }).to eq [['Sekunden', [22.1, 25.0]]]
      expect(rendered_charts.last.options[:xAxis][:categories])
        .to eq ['01.05.2016', '01.05.2018']
    end
  end

  describe '#discipline_invalid' do
    it 'counts valid and invalid scores' do
      scores = [2200, Firesport::INVALID_TIME, Firesport::INVALID_TIME].map { |time| build(:group_score, time:) }
      chart.discipline_invalid(:la, scores)
      expect(series.first[:name]).to eq 'Löschangriff nass'
      expect(series.first[:data]).to eq [
        { name: 'Ungültig', y: 2, color: 'red' },
        { name: 'Gültig', y: 1, color: 'green' },
      ]
    end
  end

  describe 'rendering' do
    it 'wraps the chart in M3.ready for regular requests' do
      output = chart.discipline_invalid(:la, [])
      expect(output).to include('M3.ready(function(){')
      div_id = output[/high-chart-\h{12}/]
      expect(output).to include("$('##{div_id}').length === 0")
      expect(output).to include("<div id=\"#{div_id}\"></div>")
    end

    it 'renders the chart directly for xhr requests' do
      chart.request = instance_double(ActionDispatch::Request, xhr?: true)
      output = chart.discipline_invalid(:la, [])
      expect(output).not_to include('M3.ready')
      expect(output).to include('new Highcharts.Chart(options)')
    end
  end
end
