# frozen_string_literal: true
class Chart::EventIndex < Chart::Base
  attr_accessor :events

  def events_count
    hc = lazy_high_chart
    data = events.sort_by(&:count).reverse.map do |event|
      {
        name: event.to_s,
        y: event.count,
      }
    end
    hc.plotOptions(series: { pointWidth: 6 })
    hc.xAxis(categories: data.map { |d| d[:name] })
    hc.legend(enabled: false)
    hc.series(name: 'Wettkämpfe', data: data)
    hc.chart(type: 'bar', height: events.count * 15)
    render(hc)
  end
end
