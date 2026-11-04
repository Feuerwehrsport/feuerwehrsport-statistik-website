# frozen_string_literal: true

# Collects Highcharts options (replacement for the lazy_high_charts gem)
class Chart::HighChart
  OPTION_NAMES = %i[title subtitle legend xAxis yAxis tooltip credits plotOptions chart].freeze

  attr_reader :options, :series_data

  OPTION_NAMES.each do |name|
    define_method(name) { |opts = {}| @options[name] = opts }
  end

  def initialize
    @options = {}
    @series_data = []
    title(text: nil)
    legend(layout: 'vertical', style: {})
    xAxis({})
    yAxis(title: { text: nil }, labels: {})
    tooltip(enabled: true)
    credits(enabled: false)
    plotOptions(areaspline: {})
    chart(defaultSeriesType: 'line', renderTo: nil)
    subtitle({})
  end

  def series(opts = {})
    @series_data.push(opts) if opts.present?
  end

  # options for Highcharts with camelized keys (snake_case keys are allowed in ruby)
  def to_h
    self.class.camelize_keys(options.merge(series: series_data))
  end

  def self.camelize_keys(value)
    case value
    when Hash then value.to_h { |key, v| [key.to_s.camelize.gsub(/\b\w/, &:downcase), camelize_keys(v)] }
    when Array then value.map { |v| camelize_keys(v) }
    else value
    end
  end
end
