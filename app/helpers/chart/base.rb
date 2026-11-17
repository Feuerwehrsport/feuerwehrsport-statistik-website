# frozen_string_literal: true

# Builds Chart.js configurations. The chart_controller (Stimulus) renders them and adds the shared styling.
class Chart::Base
  include ActiveModel::Model
  include ActionView::Helpers::TagHelper

  # categorical order (checked for colour vision deficiencies), "Andere" is always gray
  PALETTE = %w[#1D4ED8 #B91C1C #0D9488 #7C3AED #EA580C].freeze
  OTHER_COLOR = '#9AA4AF'
  # ordered groups (e.g. number of participants): one hue from light to dark
  SEQUENTIAL = %w[#BFDBFE #93C5FD #60A5FA #3B82F6 #1D4ED8 #1E3A8A].freeze
  VALID_COLOR = '#0D9488'
  INVALID_COLOR = '#B91C1C'

  delegate :t, to: I18n

  protected

  def render_chart(type:, data:, height:, options: {}, format: nil)
    config = { type:, data:, options:, format: }.compact
    tag.div(class: 'chart-box', style: "height: #{height}px") do
      tag.canvas(role: 'img', aria: { label: data[:datasets].pluck(:label).compact.uniq.join(', ') },
                 data: { controller: 'chart', chart_config_value: config.to_json })
    end
  end

  # slices: [{ name:, y:, color: }], colours default to the palette, empty slices are skipped
  def pie_chart(slices, name:, height: 150)
    slices = slices.select { |slice| slice[:y].to_i.positive? }
    background = slices.each_with_index.map { |slice, i| slice[:color] || PALETTE[i] || OTHER_COLOR }
    render_chart(type: 'doughnut', height:, data: {
                   labels: slices.pluck(:name),
                   datasets: [{ label: name, data: slices.pluck(:y), backgroundColor: background }],
                 })
  end

  def valid_pie_chart(name, valid:, invalid:)
    slices = [{ name: 'Gültig', y: valid, color: VALID_COLOR }, { name: 'Ungültig', y: invalid, color: INVALID_COLOR }]
    pie_chart(slices, name:, height: 110)
  end

  def bar_chart(labels:, values:, name:, height:, horizontal: false, colors: nil, max: nil, names: nil)
    value_axis = horizontal ? :x : :y
    options = { indexAxis: horizontal ? 'y' : 'x', plugins: { legend: { display: false } } }
    options[:scales] = { value_axis => { max: } } if max
    render_chart(type: 'bar', height:, options:, data: {
                   labels:,
                   datasets: [{ label: name, data: values, backgroundColor: colors || PALETTE.first, names: }.compact],
                 })
  end

  # datasets: [{ label:, data:, color:, dashed: }], times are given in seconds
  def line_chart(labels:, datasets:, height:, format: 'seconds', legend: false, points: nil, names: nil)
    points = labels.size <= 40 if points.nil? # many points would only clutter the line
    datasets = datasets.reject { |dataset| dataset[:data].compact.empty? }.each_with_index.map do |dataset, i|
      color = dataset[:color] || PALETTE[i] || OTHER_COLOR
      {
        label: dataset[:label], data: dataset[:data], borderColor: color, backgroundColor: color,
        borderDash: dataset[:dashed] ? [6, 4] : nil, pointRadius: points ? 2.5 : 0, spanGaps: true, names:
      }.compact
    end
    render_chart(type: 'line', height:, format:, data: { labels:, datasets: },
                 options: { plugins: { legend: { display: legend } } })
  end

  def basic_gender_pie(data)
    pie_chart(data, name: 'Geschlecht')
  end
end
