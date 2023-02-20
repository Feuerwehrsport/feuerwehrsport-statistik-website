# frozen_string_literal: true
class GroupScoreSerializer < ActiveModel::Serializer
  attributes :id, :team_id, :team_number, :gender, :time, :group_score_category_id, :run,
             :discipline, :second_time, :translated_discipline_name, :similar_scores

  def similar_scores
    object.similar_scores.decorate.map do |score|
      hash = {
        id: score.id,
        time: score.time,
        second_time: score.second_time,
      }

      participations = score.person_participations.joins(:person).pluck(:position, :person_id, :first_name, :last_name)
      (1..7).each do |position|
        participation = participations.find { |part| part.first == position } || [nil, nil, nil, nil]
        hash[:"person_#{position}"] = participation[1]
        hash[:"person_#{position}_first_name"] = participation[2]
        hash[:"person_#{position}_last_name"] = participation[3]
      end
      hash
    end
  end
end
