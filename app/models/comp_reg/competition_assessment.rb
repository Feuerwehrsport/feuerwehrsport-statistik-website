module CompReg
  class CompetitionAssessment < ActiveRecord::Base
    include Genderable
    belongs_to :competition

    validates :competition, :discipline, :gender, presence: true

    scope :requestable_for, -> (entity) do
      all_disciplines = where(competition_id: entity.competition_id)
      all_disciplines = all_disciplines.gender(entity.gender) if entity.gender.present?
      all_disciplines = all_disciplines.where.not(discipline: Discipline::GROUP) if entity.is_a?(Person)
      all_disciplines = all_disciplines.where(discipline: Discipline::GROUP) if entity.is_a?(Team)
      all_disciplines
    end

    scope :requestable_for_person, -> (team) do
      where(competition_id: team.competition_id, gender: team.gender).where.not(discipline: Discipline::GROUP)
    end
  end
end
