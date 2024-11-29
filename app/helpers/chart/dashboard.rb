# frozen_string_literal: true

class Chart::Dashboard < Chart::Base
  include DisciplineNamesAndImages
  include GenderNames

  def year_overview
    lazy_high_chart do |hc|
      hc.xAxis(categories: years, labels: { style: { fontSize: '8px' } })
      hc.yAxis(allowDecimals: false, title: false, endOnTick: false)
      hc.chart(type: 'line', height: 250)

      %i[hb hl].each do |discipline|
        Genderable::GENDERS.each_key do |gender|
          hc.series(
            name: "#{discipline_name_short(discipline)} #{g_symbol(gender)}",
            data: averages(discipline, gender),
            lineWidth: 1,
            marker: { enabled: false },
          )
        end
      end
      hc.tooltip(shared: true)
      hc.legend(enabled: false)
    end
  end

  protected

  def years
    @years ||= (2006..Time.current.year).to_a
  end

  def competition_ids_for_year(year)
    @competition_ids_for_year ||= {}
    @competition_ids_for_year[year] ||= Competition.year(year).pluck(:id)
  end

  def averages(key, gender)
    years.map do |year|
      single_discipline = SingleDiscipline.default_for(key, gender, year)
      scores = Score.valid.where(single_discipline:).gender(gender)
      with_sql = scores
                 .select(:competition_id)
                 .where(competition_id: competition_ids_for_year(year))
                 .group(:competition_id)
                 .having('COUNT(*) >= 20')
                 .to_sql
      scores_sql = scores
                   .best_of_competition
                   .select('time, ROW_NUMBER() OVER (PARTITION BY competition_id ORDER BY time) AS r')
                   .where('competition_id IN (SELECT * FROM with_competitions)')
                   .to_sql
      sql = "WITH with_competitions AS (#{with_sql}) SELECT AVG(s.time) FROM (#{scores_sql}) s WHERE s.r <= 5"
      average = Score.connection.select_all(sql).first['avg']
      average.present? ? (average.to_f / 100).round(2) : nil
    end
  end
end
