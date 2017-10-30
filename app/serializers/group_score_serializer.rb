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
      positions = score.person_participations.pluck(:position, :person_id).to_h
      (1..7).each { |position| hash[:"person_#{position}"] = positions[position] }
      hash
    end
  end
end
