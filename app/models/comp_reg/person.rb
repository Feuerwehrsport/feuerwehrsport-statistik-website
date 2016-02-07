module CompReg
  class Person < ActiveRecord::Base
    include Genderable
    belongs_to :competition
    has_many :person_assessment_participations, inverse_of: :person
    belongs_to :team

    validates :first_name, :last_name, :gender, :competition, presence: true

    accepts_nested_attributes_for :person_assessment_participations, reject_if: :all_blank, allow_destroy: true

    before_validation do
      self.gender = team.gender if team.present? && gender.nil?
      self.competition = team.competition if team.present? && competition.nil?
    end

    def gender
      super || team.try(:gender)
    end

    def competition_id
      super || team.try(:competition_id)
    end
  end
end
