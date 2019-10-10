module Chart
  class TeamShow < Base
    attr_accessor :team

    def gender_pie
      data = team.members.group(:gender).count.map do |key, count|
        {
          name: g(key),
          y: count,
          color: gender_color(key),
        }
      end
      basic_gender_pie(data)
    end

    def group_discipline_scores(scores)
      scores = scores.sort_by { |s| s.object.competition.date }
      hc = lazy_high_chart
      hc.xAxis(categories: scores.map(&:competition).map(&:date), labels: { enabled: false, rotation: 270, style: { fontSize: '8px' } })
      hc.series(name: 'Sekunden', yAxis: 0, data: scores.map { |s| s.time.to_f / 100 }, lineWidth: 1)
      hc.yAxis [title: { text: 'Sekunden', margin: 20 }, endOnTick: false]
      hc.legend(enabled: false)
      hc.tooltip(shared: true)
      hc.chart(type: 'line', height: 220, marginRight: 50)
      render(hc)
    end

    def discipline_invalid(discipline, scores)
      invalid = scores.count(&:time_invalid?)
      valid = scores.size - invalid
      data = [{ name: 'Ungültig', y: invalid, color: 'red' }, { name: 'Gültig', y: valid, color: 'green' }]

      hc = lazy_high_chart
      hc.series(name: discipline_name(discipline), data: data)
      hc.plotOptions(pie: { size: 70, dataLabels: { distance: 0, format: '{percentage:.1f} % {point.name}' } })
      hc.chart(type: 'pie', height: 90)
      render(hc)
    end
  end
end
