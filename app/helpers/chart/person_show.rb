# frozen_string_literal: true

class Chart::PersonShow < Chart::Base
  include DisciplineNamesAndImages
  include Helper::PositionSelectorHelper

  attr_accessor :person, :team_structs

  def year_overview
    return '' if person.scores.valid.blank?

    datasets = SingleDiscipline.gall.map do |sd|
      { label: sd.short_name, data: year_overview_data.for(sd.id), color: discipline_color(sd.key) }
    end
    line_chart(labels: year_overview_data.years, datasets:, height: 220, legend: true)
  end

  def discipline_invalid(name, scores)
    invalid = scores.count(&:time_invalid?)
    valid_pie_chart(name, valid: scores.size - invalid, invalid:)
  end

  def discipline_scores(discipline, chart_scores)
    times = chart_scores.map { |s| s.time.to_f / 100 }
    datasets = [{ label: 'Zeit', data: times, color: discipline_color(discipline) }]
    if discipline.to_s == 'zk'
      datasets.push({ label: 'HB', data: chart_scores.map { |s| s.hb.to_f / 100 }, color: discipline_color(:hb),
                      dashed: true },
                    { label: 'HL', data: chart_scores.map { |s| s.hl.to_f / 100 }, color: discipline_color(:hl),
                      dashed: true })
    end
    line_chart(labels: chart_scores.map { |s| s.competition.date }, names: chart_scores.map { |s| s.competition.to_s },
               datasets:, height: 220, legend: datasets.size > 1)
  end

  def discipline_positions(discipline)
    position_counts = @person.group_score_participations.where(discipline:)
                             .group(:position).order(:position).count.map do |position, count|
      { name: competitor_position(discipline, position, @person.gender), y: count }
    end
    pie_chart(position_counts, name: 'Läufe')
  end

  def team_scores_count(team_struct)
    @max_team_scores ||= %i[hb hl gs fs la].map do |discipline|
      team_structs.pluck(discipline).max
    end.max

    disciplines = %i[hb hl gs fs la].select { |discipline| team_struct[discipline] > 0 }
    bar_chart(labels: disciplines.map { |d| discipline_name(d) }, values: disciplines.map { |d| team_struct[d] },
              colors: disciplines.map { |d| discipline_color(d) }, name: 'Zeiten', horizontal: true,
              max: @max_team_scores, height: (disciplines.size * 22) + 40)
  end

  private

  def year_overview_data
    @year_overview_data ||= YearOverviewData.new(person.id)
  end

  class YearOverviewData
    def initialize(person_id)
      sql = <<~SQL.squish
        SELECT c.year AS year, s.single_discipline_id, AVG(s.time) AS average_time
        FROM scores s
        JOIN competitions c ON s.competition_id = c.id
        WHERE s.person_id = ? AND s.time != ?
        GROUP BY c.year, s.single_discipline_id
        ORDER BY c.year
      SQL
      @result = ActiveRecord::Base.connection.select_all(
        ActiveRecord::Base.sanitize_sql_array([sql, person_id, Firesport::INVALID_TIME]),
      ).to_a
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
