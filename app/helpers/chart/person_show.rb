# frozen_string_literal: true

class Chart::PersonShow < Chart::Base
  include DisciplineNamesAndImages
  include Helper::PositionSelectorHelper
  attr_accessor :person, :team_structs

  def year_overview
    return '' if person.scores.valid.blank?

    lazy_high_chart do |hc|
      hc.xAxis(categories: year_overview_data.years, labels: { rotation: 270, style: { fontSize: '8px' } })
      SingleDiscipline.gall.each do |sd|
        hc.series(name: sd.short_name, yAxis: 0,
                  data: year_overview_data.for(sd.id), lineWidth: 1, color: discipline_color(sd.key))
      end

      hc.yAxis [title: { text: 'Sekunden', margin: 20 }, endOnTick: false]
      hc.legend(enabled: false)
      hc.tooltip(shared: true)
      hc.chart(type: 'line', height: 200)
    end
  end

  def discipline_invalid(name, scores)
    invalid = scores.count(&:time_invalid?)
    valid = scores.size - invalid
    data = [{ name: 'Ungültig', y: invalid, color: 'red' }, { name: 'Gültig', y: valid, color: 'green' }]

    lazy_high_chart do |hc|
      hc.series(name: name, data:)
      hc.plotOptions(pie: { size: 70, dataLabels: { distance: 0, format: '{percentage:.1f} % {point.name}' } })
      hc.chart(type: 'pie', height: 90)
    end
  end

  def discipline_scores(discipline, chart_scores)
    lazy_high_chart do |hc|
      hc.xAxis(categories: chart_scores.map { |s| s.competition.date },
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
    end
  end

  def discipline_positions(discipline)
    position_counts = @person.group_score_participations.where(discipline:)
                             .group(:position).count.map do |position, count|
      { name: competitor_position(discipline, position, @person.gender), y: count }
    end

    lazy_high_chart do |hc|
      hc.series(name: 'Läufe', data: position_counts)
      hc.plotOptions(pie: { size: 70, dataLabels: { distance: 5, format: '{percentage:.1f} % {point.name}' } })
      hc.chart(type: 'pie', height: 140)
    end
  end

  def team_scores_count(team_struct)
    @max_team_scores ||= %i[hb hl gs fs la].map do |discipline|
      team_structs.pluck(discipline).max
    end.max

    lazy_high_chart do |hc|
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
      hc.series(name: 'Läufe', data:)
      hc.chart(type: 'bar', height: 140)
    end
  end

  private

  def year_overview_data
    @year_overview_data ||= YearOverviewData.new(person.id)
  end

  class YearOverviewData
    def initialize(person_id)
      @result = ActiveRecord::Base.connection.execute(<<-SQL.squish).to_a
        SELECT#{' '}
          c.year AS year,
          s.single_discipline_id,
          AVG(s.time) AS average_time
        FROM#{' '}
          scores s
        JOIN#{' '}
          competitions c ON s.competition_id = c.id
        WHERE#{' '}
          s.person_id = #{person_id} and s.time != #{Firesport::INVALID_TIME}
        GROUP BY#{' '}
          c.year, s.single_discipline_id
        ORDER BY#{' '}
          c.year;
      SQL
    end

    def years
      @years ||= begin
        ys = @result.pluck('year')
        (ys.min..ys.max).to_a
      end
    end

    def for(sd_id)
      years.map do |year|
        average_time = @result.find { |r| r['year'] == year && r['single_discipline_id'] == sd_id }
                              &.fetch('average_time', nil)
        average_time = (average_time / 100).round(2).to_f unless average_time.nil?
        average_time
      end
    end
  end
end
