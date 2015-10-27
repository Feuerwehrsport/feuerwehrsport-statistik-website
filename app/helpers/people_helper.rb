module PeopleHelper
  def genders_pie_chart
    chart = LazyHighCharts::HighChart.new do |f|
      f.series(name: "Anzahl", data: Person.group(:gender).count.map { |i, c| { name: g(i), y: c, color: g_color(i) } })
      f.plotOptions(pie: { size: 70, dataLabels: { distance: 5, format: "{percentage:.1f} % {point.name}" } })
      f.chart(type: "pie", height: 140)
    end
    high_chart("high-chart-gender-pie", chart)
  end

  def disciplines_pie_chart(gender)
    scores = Score.joins(:person).merge(Person.gender(gender)).group(:discipline).count.merge(
      GroupScoreParticipation.joins(:person).merge(Person.gender(gender)).group(:discipline).count).map{|i, a| {name: i.upcase, y: a, color: discipline_color(i)}}

    chart = LazyHighCharts::HighChart.new do |f|
      f.series(name: "Anzahl", data: scores)
      f.plotOptions(pie: { size: 70, dataLabels: { distance: 5, format: "{percentage:.1f} % {point.name}" } })
      f.chart(type: "pie", height: 140)
    end
    high_chart("high-chart-disciplines-pie-#{gender}", chart)
  end

  def discipline_invalid_chart(discipline, scores)
    invalid = scores.select(&:invalid?).size
    valid = scores.size - invalid

    chart = LazyHighCharts::HighChart.new do |f|
      f.series(name: discipline_name(discipline), data: [{ name: "Ungültig", y: invalid, color: "red"}, {name: "Gültig", y: valid, color: "green"}])
      f.plotOptions(pie: { size: 70, dataLabels: { distance: 0, format: "{percentage:.1f} % {point.name}" } })
      f.chart(type: "pie", height: 90)
    end
    high_chart("high-chart-invalid-#{discipline}", chart)
  end

  def discipline_chart(discipline, chart_scores)
    chart = LazyHighCharts::HighChart.new do |f|
      f.xAxis(categories: chart_scores.map(&:competition).map(&:date), labels: { rotation: 270 , style: { fontSize: "8px" }})
      f.series(name: "Sekunden", yAxis: 0, data: chart_scores.map{ |s| s.time.to_f/100 }, lineWidth: 1)
      if discipline == :zk
        f.series(name: "HB", yAxis: 0, data: chart_scores.map{ |s| s.hb.to_f/100 }, lineWidth: 1, marker: { enabled: false })
        f.series(name: "HL", yAxis: 0, data: chart_scores.map{ |s| s.hl.to_f/100 }, lineWidth: 1, marker: { enabled: false })
      end
      f.yAxis [ title: { text: "Sekunden", margin: 20 }, endOnTick: false]
      f.legend(enabled: false)
      f.tooltip(shared: true)
      f.chart(type: "line", height: 220, marginRight: 50)
    end
    high_chart("high-chart-#{discipline}", chart)
  end

  def year_overview_chart
    if @year_overview.present?
      chart = LazyHighCharts::HighChart.new do |f|
        f.xAxis(categories: @year_overview.map(&:third),labels: { rotation: 270 , style: { fontSize: "8px" }})
        f.series(name: "HB", yAxis: 0, data: @year_overview.map(&:first), lineWidth: 1, color: discipline_color(:hb))
        f.series(name: "HL", yAxis: 0, data: @year_overview.map(&:second), lineWidth: 1, color: discipline_color(:hl))
        f.yAxis [ title: { text: "Sekunden", margin: 20 }, endOnTick: false]
        f.legend(enabled: false)
        f.tooltip(shared: true)
        f.chart(type: "line", height: 200)
      end
      high_chart("high-chart-year-overview-", chart)
    end
  end

  def discipline_positions_chart(discipline)
    position_counts = @person.group_score_participations.where(discipline: discipline).group(:position).count.map do |position, count|
      { name: competitor_position(discipline, position, @person.gender), y: count }
    end

    chart = LazyHighCharts::HighChart.new do |f|
      f.series(name: "Läufe", data: position_counts)
      f.plotOptions(pie: { size: 70, dataLabels: { distance: 5, format: "{percentage:.1f} % {point.name}" } })
      f.chart(type: "pie", height: 140)
    end
    high_chart("high-chart-positions-#{discipline}", chart)
  end

  def team_information_chart(team_information)
    @max_team_scores ||= begin 
      [:hb, :hl, :gs, :fs, :la].map do |discipline|
        @team_information.map { |ti| ti[discipline] }.max
      end.max
    end
    chart = LazyHighCharts::HighChart.new do |f|
      data = []
      [:hb, :hl, :gs, :fs, :la].each do |discipline|
        if team_information[discipline] > 0
          data.push(name: discipline_name(discipline), y: team_information[discipline], color: discipline_color(discipline))
        end
      end
      f.plotOptions(series: {pointWidth: 6})
      f.xAxis(categories: data.map { |d| d[:name] })
      f.yAxis(max: @max_team_scores, title: { text: "Zeiten" })
      f.legend(enabled: false)
      f.series(name: "Läufe", data: data)
      f.chart(type: "bar", height: 140)
    end
    high_chart("high-chart-team-information-#{team_information.team.id}", chart)
  end
end