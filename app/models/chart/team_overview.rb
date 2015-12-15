module Chart
  class TeamOverview < Base
    def federal_states_pie
      data = Team.where(state: State::FEDERAL).group(:state).count
      states_pie(data)
    end

    def international_states_pie
      data = Team.where(state: State::INTERNATIONAL).where.not(state: "DE").group(:state).count
      states_pie(data)
    end

    protected

    def states_pie(data)
      data = data.map { |k,v| { short_name: k, name: State::ALL[k], y: v } }
      data = data.reject { |a| a[:y].blank? }.sort_by { |a| a[:y] }.reverse
      hc = lazy_high_chart
      hc.legend(enabled: false)
      hc.chart(type: "column", height: 120)
      hc.plotOptions(series: { pointWidth: 6 })
      hc.yAxis(endOnTick: false, title: nil)
      hc.xAxis(categories: data.map {|a| a[:short_name] })
      hc.series(name: "Mannschaften", data: data)
      render(hc)
    end
  end
end