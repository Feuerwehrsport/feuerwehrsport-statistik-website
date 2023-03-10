# frozen_string_literal: true

class Chart::YearIndex < Chart::Base
  attr_accessor :years

  def years_count
    hc = lazy_high_chart
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
    render(hc)
  end
end
