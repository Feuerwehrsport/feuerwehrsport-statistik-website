# frozen_string_literal: true

class Chart::YearIndex < Chart::Base
  attr_accessor :years

  def competitions_count
    lazy_high_chart do |hc|
      data = years.sort_by(&:to_s).reverse.map do |year|
        {
          name: year.to_s,
          y: year.count,
        }
      end
      hc.plotOptions(series: { pointWidth: 6 })
      hc.xAxis(categories: data.pluck(:name))
      hc.legend(enabled: false)
      hc.series(name: 'Wettkämpfe', data:)
      hc.chart(type: 'bar', height: years.count * 15)
    end
  end
end
