# frozen_string_literal: true

class Chart::TeamShow < Chart::Base
  include DisciplineNamesAndImages
  include GenderNames

  attr_accessor :team

  def gender_pie
    data = team.members.group(:gender).count.map do |key, count|
      {
        name: g(key),
        y: count,
        color: gender_color(key),
      }
    end
    basic_gender_pie(data)
  end

  def group_discipline_scores(discipline, scores)
    scores = scores.sort_by { |s| s.object.competition.date }
    line_chart(labels: scores.map { |s| s.competition.date }, names: scores.map { |s| s.competition.to_s },
               datasets: [{ label: 'Zeit', data: scores.map { |s| s.time.to_f / 100 },
                            color: discipline_color(discipline) }], height: 220)
  end

  def discipline_invalid(discipline, scores)
    invalid = scores.count(&:time_invalid?)
    valid_pie_chart(discipline_name(discipline), valid: scores.size - invalid, invalid:)
  end
end
