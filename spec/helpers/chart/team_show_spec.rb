# frozen_string_literal: true

require 'rails_helper'

describe Chart::TeamShow do
  let(:team) { create(:team) }
  let(:chart) { described_class.new(team:) }
  let(:rendered_charts) { [] }

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

  def slices
    config[:data][:labels].zip(datasets.first[:data], datasets.first[:backgroundColor])
  end

  describe '#gender_pie' do
    before do
      create(:score, team:, person: create(:person))
      create(:score, team:, person: create(:person, first_name: 'Bernd'))
      create(:score, team:, person: create(:person, :female))
    end

    it 'counts members per gender' do
      output = chart.gender_pie
      expect(output).to include('data-controller="chart"')
      expect(config).to include(type: 'doughnut', height: 150)
      expect(datasets.first[:label]).to eq 'Geschlecht'
      expect(slices.map { |name, y, _color| [name, y] }).to contain_exactly(
        [I18n.t('gender.male'), 2],
        [I18n.t('gender.female'), 1],
      )
    end

    it 'colors the gender slices' do
      chart.gender_pie
      expect(slices).to contain_exactly(
        [I18n.t('gender.male'), 2, '#1D4ED8'],
        [I18n.t('gender.female'), 1, '#EA580C'],
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

      chart.group_discipline_scores(:la, scores)
      expect(datasets.map { |s| [s[:label], s[:data]] }).to eq [['Zeit', [22.1, 25.0]]]
      expect(config[:data][:labels]).to eq ['01.05.2016', '01.05.2018']
    end
  end

  describe '#discipline_invalid' do
    it 'counts valid and invalid scores' do
      scores = [2200, Firesport::INVALID_TIME, Firesport::INVALID_TIME].map { |time| build(:group_score, time:) }
      chart.discipline_invalid(:la, scores)
      expect(datasets.first[:label]).to eq 'Löschangriff nass'
      expect(slices).to eq [['Gültig', 1, Chart::Base::VALID_COLOR], ['Ungültig', 2, Chart::Base::INVALID_COLOR]]
    end
  end

  describe 'rendering' do
    it 'renders a canvas with the configuration for the chart controller' do
      output = chart.discipline_invalid(:la, [build(:group_score, time: 2200)])
      html = Nokogiri::HTML.fragment(output)
      expect(html.at_css('.chart-box')['style']).to eq 'height: 110px'
      canvas = html.at_css('canvas[data-controller="chart"]')
      expect(canvas['aria-label']).to eq 'Löschangriff nass'
      expect(JSON.parse(canvas['data-chart-config-value'])).to include('type' => 'doughnut')
    end

    it 'skips empty slices' do
      chart.discipline_invalid(:la, [build(:group_score, time: 2200)])
      expect(slices).to eq [['Gültig', 1, Chart::Base::VALID_COLOR]]
    end
  end
end
