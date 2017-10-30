module Import
  class Scores
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :discipline, :gender, :scores, :competition_id, :group_score_category_id

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
            insert_hash[:group_score_category_id] = group_score_category_id
            insert_hash[:gender] = gender
            insert_hash[:run] = (discipline == :fs ? score[:run] : '')

            score[:times].each do |time|
              insert_hash[:time] = time
              GroupScore.create!(insert_hash)
            end
          else
            if score[:person_id]
              person = Person.find_by(id: score[:person_id])
            else
              person_ids = Person.gender(gender).search_exactly(score[:last_name], score[:first_name]).pluck(:id)
              person_ids += PersonSpelling.gender(gender).search_exactly(score[:last_name], score[:first_name]).pluck(:person_id)
              person = Person.where(id: person_ids).first
            end
            if person.nil?
              person = Person.create!(
                gender: gender,
                last_name: score[:last_name],
                first_name: score[:first_name],
                nation_id: 1,
              )
            end

            insert_hash[:person] = person
            insert_hash[:competition_id] = competition_id
            insert_hash[:discipline] = discipline

            score[:times].each do |time|
              insert_hash[:time] = time
              Score.create!(insert_hash)
            end
          end
        end
      end
    end
  end
end
