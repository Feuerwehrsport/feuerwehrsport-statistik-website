# frozen_string_literal: true

class Chart::PersonIndex < Chart::Base
  include GenderNames
  include DisciplineNamesAndImages

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
    single_scores_count = Score.joins(:person).merge(Person.gender(gender)).joins(:single_discipline)
                               .group(:'single_disciplines.key').count
    group_scores_count = GroupScoreParticipation.joins(:person).merge(Person.gender(gender))
                                                .group(:discipline).count
    scores = single_scores_count.merge(group_scores_count).sort_by { |discipline, _count| discipline }
                                .map do |discipline, count|
      { name: discipline.upcase, y: count, color: discipline_color(discipline) }
    end
    pie_chart(scores, name: "Zeiten #{g(gender)}")
  end
end
