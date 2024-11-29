# frozen_string_literal: true

class ScoreSerializer < ActiveModel::Serializer
  attributes :id, :team_id, :team_number, :time, :single_discipline_id, :second_time, :translated_discipline_name,
             :similar_scores, :person, :discipline_key

  def similar_scores
    Score.where(competition_id: object.competition_id, person_id: object.person_id).order(:id).decorate.map do |score|
      {
        id: score.id,
        time: score.time,
        second_time: score.second_time,
        discipline_key: score.single_discipline.key,
        translated_discipline_name: score.translated_discipline_name,
        team_id: score.team_id,
        team_number: score.team_number,
      }
    end
  end

  def person
    object.person&.full_name
  end
end
