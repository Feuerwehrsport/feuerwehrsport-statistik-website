# frozen_string_literal: true

class Chart::PersonIndex < Chart::Base
  def gender_pie
    data = Genderable::GENDER_KEYS.map do |gender|
      {
        name: g(gender),
        y: Person.gender(gender).count,
        color: gender_color(gender),
      }
    end
    basic_gender_pie(data)
  end

  def disciplines_pie(gender)
    single_scores_count = Score.joins(:person).merge(Person.gender(gender)).group(:discipline).count
    group_scores_count = GroupScoreParticipation.joins(:person).merge(Person.gender(gender)).group(:discipline).count
    scores = single_scores_count.merge(group_scores_count).map do |discipline, count|
      {
        name: discipline.upcase,
        y: count,
        color: discipline_color(discipline),
      }
    end

    hc = lazy_high_chart
    hc.series(name: 'Anzahl', data: scores)
    hc.plotOptions(pie: { size: 70, dataLabels: { distance: 5, format: '{percentage:.1f} % {point.name}' } })
    hc.chart(type: 'pie', height: 150)
    render(hc)
  end
end
