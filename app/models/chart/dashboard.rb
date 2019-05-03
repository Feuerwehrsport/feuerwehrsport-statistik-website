module Chart
  class Dashboard < Base
    def year_overview
      hc = lazy_high_chart
      hc.xAxis(categories: years, labels: { style: { fontSize: '8px' } })
      hc.yAxis(allowDecimals: false, title: false, endOnTick: false)
      hc.chart(type: 'line', height: 250)

      %i[hb hl].each do |discipline|
        %i[female male].each do |gender|
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
      render(hc)
    end

    protected

    def years
      @years ||= (2006..Time.current.year).to_a
    end

    def competition_ids_for_year(year)
      @competition_ids_for_year ||= {}
      @competition_ids_for_year[year] ||= Competition.year(year).pluck(:id)
    end

    def averages(discipline, gender)
      years.map do |year|
        discipline = :hw if year > 2016 && discipline == :hb && gender == :female
        scores = Score.valid.discipline(discipline).gender(gender)
        with_sql = scores
                   .select(:competition_id)
                   .where(competition_id: competition_ids_for_year(year))
                   .group(:competition_id)
                   .having('COUNT(*) >= 20')
                   .to_sql
        scores_sql = scores
                     .best_of_competition
                     .select('ROW_NUMBER() OVER (PARTITION BY competition_id ORDER BY time) AS r')
                     .where('competition_id IN (SELECT * FROM with_competitions)')
                     .to_sql
        sql = "WITH with_competitions AS (#{with_sql}) SELECT AVG(s.time) FROM (#{scores_sql}) s WHERE s.r <= 5"
        average = Score.connection.select_all(sql).first['avg']
        average.present? ? (average.to_f / 100).round(2) : nil
      end
    end
  end
end
