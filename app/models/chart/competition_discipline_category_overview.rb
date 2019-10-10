module Chart
  class CompetitionDisciplineCategoryOverview < Base
    attr_accessor :discipline

    def discipline_scores
      discipline.scores.reject(&:time_invalid?)
    end

    def group_scores_overview
      scores = discipline_scores.map { |s| { y: s.time.to_f / 100, name: numbered_team_name(s) } }
      scores_overview(scores)
    end

    def single_scores_overview
      scores = discipline_scores.map { |s| { y: s.time.to_f / 100, name: s.person.to_s } }
      scores_overview(scores)
    end

    def double_event_scores_overview
      all_scores = discipline_scores.sort_by(&:time)
      scores = all_scores.map { |s| { y: s.time.to_f / 100, name: s.person.short_name } }
      hb = all_scores.map { |s| { y: s.hb.to_f / 100, name: s.person.short_name } }
      hl = all_scores.map { |s| { y: s.hl.to_f / 100, name: s.person.short_name } }
      scores_overview(scores, hb: hb, hl: hl)
    end

    def scores_overview(scores, options = {})
      scores.sort_by! { |a| a[:y] }
      hc = lazy_high_chart
      hc.xAxis(categories: scores.each_with_index.map { |_s, i| "#{i + 1}." }, labels: { style: { fontSize: '8px' } })
      hc.yAxis(allowDecimals: false, title: { text: 'Zeit (s)' })
      hc.chart(type: 'line', height: 120)
      hc.series(name: discipline_name(discipline.discipline), data: scores, lineWidth: 1)
      if options[:hb].present?
        hc.series(name: discipline_name(:hb), data: options[:hb], lineWidth: 1, marker: { enabled: false })
      end
      if options[:hb].present?
        hc.series(name: discipline_name(:hl), data: options[:hl], lineWidth: 1, marker: { enabled: false })
      end
      hc.tooltip(shared: true)
      hc.legend(enabled: false)
      render(hc)
    end

    def invalid_pie
      valid = discipline.all_scores.valid.count
      invalid = discipline.all_scores.count - valid

      hc = lazy_high_chart
      hc.series(name: discipline_name(discipline.discipline), data: [{ name: 'Ungültig', y: invalid, color: 'red' }, { name: 'Gültig', y: valid, color: 'green' }])
      hc.plotOptions(pie: { size: 60, dataLabels: { distance: 0, format: '{percentage:.1f} %' } })
      hc.chart(type: 'pie', height: 90)
      render(hc)
    end
  end
end
