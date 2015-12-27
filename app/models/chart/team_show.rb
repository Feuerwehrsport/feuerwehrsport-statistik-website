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

      hc = lazy_high_chart
      hc.legend(borderWidth: 0, margin: 0, padding: 5)
      hc.chart(type: "pie", height: 150)
      hc.plotOptions(pie: { dataLabels: { enabled: false }, showInLegend: true })
      # hc.yAxis(endOnTick: false, title: nil)
      # hc.xAxis(categories: data.map {|a| a[:short_name] })
      hc.series(name: "Geschlecht", data: data)
      render(hc)
    end
  end
end