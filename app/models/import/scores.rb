# frozen_string_literal: true

class Import::Scores
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :gender, :scores, :competition_id, :group_score_category_id, :single_discipline_id
  attr_reader :discipline

  validates :discipline, :gender, :scores, presence: true
  validates :discipline, inclusion: { in: Discipline::WITHOUT_DOUBLE_EVENT }
  validates :gender, inclusion: { in: %w[female male] }

  def discipline=(discipline)
    @discipline = discipline.try(:to_sym)
  end

  def save!
    Score.transaction do
      scores.each do |score|
        insert_hash = {
          team_number: score[:team_number].to_i,
          team: Team.find_by(id: score[:team_id]),
        }

        if Discipline.group?(discipline)
          group_score(score, insert_hash)
        else
          single_score(score, insert_hash)
        end
      end
    end
  end

  private

  def group_score(score, insert_hash)
    insert_hash[:group_score_category_id] = group_score_category_id
    insert_hash[:gender] = gender
    insert_hash[:run] = (discipline == :fs ? score[:run] : '')

    score[:times].each do |time|
      insert_hash[:time] = time
      GroupScore.create!(insert_hash)
    end
  end

  def single_score(score, insert_hash)
    if score[:person_id]
      person = Person.find_by(id: score[:person_id])
    else
      person_ids = Person.gender(gender).search_exactly(score[:last_name], score[:first_name]).pluck(:id)
      person_ids += PersonSpelling.gender(gender).search_exactly(score[:last_name], score[:first_name])
                                  .pluck(:person_id)
      person = Person.find_by(id: person_ids)
    end
    if person.nil?
      person = Person.create!(
        gender:,
        last_name: score[:last_name],
        first_name: score[:first_name],
        nation_id: 1,
      )
    end

    insert_hash[:person] = person
    insert_hash[:competition_id] = competition_id
    insert_hash[:single_discipline_id] = single_discipline_id

    score[:times].each do |time|
      insert_hash[:time] = time
      Score.create!(insert_hash)
    end
  end
end
