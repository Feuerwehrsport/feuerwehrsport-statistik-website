# frozen_string_literal: true

class Chart::PersonShow < Chart::Base
  attr_accessor :person, :team_structs

  def year_overview
    return '' if person.scores.valid.blank?

    hc = lazy_high_chart
    hc.xAxis(categories: year_overview_data.map(&:fourth), labels: { rotation: 270, style: { fontSize: '8px' } })
    hc.series(name: 'HB', yAxis: 0,
              data: year_overview_data.map(&:first), lineWidth: 1, color: discipline_color(:hb))
    hc.series(name: 'HB flach', yAxis: 0,
              data: year_overview_data.map(&:third), lineWidth: 1, color: discipline_color(:hb))
    hc.series(name: 'HL', yAxis: 0,
              data: year_overview_data.map(&:second), lineWidth: 1, color: discipline_color(:hl))
    hc.yAxis [title: { text: 'Sekunden', margin: 20 }, endOnTick: false]
    hc.legend(enabled: false)
    hc.tooltip(shared: true)
    hc.chart(type: 'line', height: 200)
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

  def discipline_scores(discipline, chart_scores)
    hc = lazy_high_chart
    hc.xAxis(categories: chart_scores.map(&:competition).map(&:date),
             labels: { enabled: false, rotation: 270, style: { fontSize: '8px' } })
    hc.series(name: 'Sekunden', yAxis: 0, data: chart_scores.map { |s| s.time.to_f / 100 }, lineWidth: 1)
    if discipline == :zk
      hc.series(name: 'HB', yAxis: 0, data: chart_scores.map { |s| s.hb.to_f / 100 },
                lineWidth: 1, marker: { enabled: false })
      hc.series(name: 'HL', yAxis: 0, data: chart_scores.map { |s| s.hl.to_f / 100 },
                lineWidth: 1, marker: { enabled: false })
    end
    hc.yAxis [title: { text: 'Sekunden', margin: 20 }, endOnTick: false]
    hc.legend(enabled: false)
    hc.tooltip(shared: true)
    hc.chart(type: 'line', height: 220, marginRight: 50)
    render(hc)
  end

  def discipline_positions(discipline)
    position_counts = @person.group_score_participations.where(discipline: discipline)
                             .group(:position).count.map do |position, count|
      { name: competitor_position(discipline, position, @person.gender), y: count }
    end

    hc = lazy_high_chart
    hc.series(name: 'Läufe', data: position_counts)
    hc.plotOptions(pie: { size: 70, dataLabels: { distance: 5, format: '{percentage:.1f} % {point.name}' } })
    hc.chart(type: 'pie', height: 140)
    render(hc)
  end

  def team_scores_count(team_struct)
    @max_team_scores ||= %i[hb hl gs fs la].map do |discipline|
      team_structs.pluck(discipline).max
    end.max

    hc = lazy_high_chart
    data = []
    %i[hb hl gs fs la].each do |discipline|
      if team_struct[discipline] > 0
        data.push(name: discipline_name(discipline), y: team_struct[discipline], color: discipline_color(discipline))
      end
    end
    hc.plotOptions(series: { pointWidth: 6 })
    hc.xAxis(categories: data.pluck(:name))
    hc.yAxis(max: @max_team_scores, title: { text: 'Zeiten' })
    hc.legend(enabled: false)
    hc.series(name: 'Läufe', data: data)
    hc.chart(type: 'bar', height: 140)
    render(hc)
  end

  private

  def year_overview_data
    @year_overview_data ||= begin
      years = person.scores.joins(:competition)
                    .select('EXTRACT(YEAR FROM DATE(competitions.date)) AS year')
                    .group('year')
                    .map(&:year)
                    .map(&:to_i)
      (years.min..years.max).map do |year|
        %i[hb hl hw].map do |discipline|
          times = person.scores
                        .where(discipline: discipline)
                        .valid
                        .best_of_competition
                        .joins(:competition)
                        .where('EXTRACT(YEAR FROM DATE(competitions.date)) = ?', year)
                        .map(&:time)
          times.present? ? (times.instance_eval { sum / size.to_f } / 100).round(2) : nil
        end.push(year)
      end
    end
  end
end
