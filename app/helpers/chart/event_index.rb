# frozen_string_literal: true

class Chart::EventIndex < Chart::Base
  attr_accessor :events

  def events_count
    lazy_high_chart do |hc|
      data = events.sort_by(&:count).reverse.map do |event|
        {
          name: event.to_s,
          y: event.count,
        }
      end
      hc.plotOptions(series: { pointWidth: 6 })
      hc.xAxis(categories: data.pluck(:name))
      hc.legend(enabled: false)
      hc.series(name: 'Wettkämpfe', data:)
      hc.chart(type: 'bar', height: events.count * 15)
    end
  end
end
