# frozen_string_literal: true

class Chart::About < Chart::Base
  def competition_creations
    lazy_high_chart do |hc|
      hc.xAxis(type: 'datetime')
      hc.chart(type: 'line', height: 800)

      [Competition, Score, GroupScore, Team, Person, Place, PersonParticipation, Link].each do |klass|
        hc.series(
          name: klass.model_name.human(count: :many),
          data: data(klass),
          step: 'left',
        )
      end
    end
  end

  def data(klass)
    dates = {}
    absolute = 0
    min_date = Date.new(2016, 5, 1)
    klass.reorder(:created_at).pluck('created_at::DATE as date').each do |date|
      date = [date, min_date].max
      dates[date.to_s] = absolute += 1
    end
    dates[Date.current.to_s] = absolute
    dates.map do |date_string, count|
      [DateTime.parse(date_string).to_i * 1000, count]
    end
  end
end
