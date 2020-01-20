class Chart::About < Chart::Base
  def competition_creations
    hc = lazy_high_chart
    hc.xAxis(type: 'datetime')
    hc.chart(type: 'line', height: 800)

    [Competition, Score, GroupScore, Team, Person, Place, Appointment, PersonParticipation, Link].each do |klass|
      hc.series(
        name: klass.model_name.human(count: :many),
        data: data(klass),
        step: 'left',
      )
    end
    render(hc)
  end

  def data(klass)
    dates = {}
    absolute = 0
    min_date = Date.new(2014, 12, 26)
    klass.reorder(:created_at).pluck('created_at::DATE as date').each do |date|
      date = min_date if date < min_date
      absolute += 1
      dates[date.to_s] ||= 0
      dates[date.to_s] = absolute
    end
    dates[Date.current.to_s] = absolute
    dates.map do |date_string, count|
      [DateTime.parse(date_string).in_time_zone, count]
    end
  end
end
