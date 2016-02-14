module CompReg
  class Person < ActiveRecord::Base
    include Genderable
    include Taggable
    belongs_to :competition
    belongs_to :admin_user
    has_many :person_assessment_participations, inverse_of: :person, dependent: :destroy
    has_many :competition_assessments, through: :person_assessment_participations
    belongs_to :team

    scope :with_assessment, -> (assessment) do
      joins(:competition_assessments).
      where(comp_reg_competition_assessments: { id: assessment })
    end
    scope :manageable_by, -> (user) do
      person_sql = Person.joins(:competition).merge(Competition.open).where(admin_user_id: user.id).select(:id).to_sql
      competition_sql = Person.joins(:competition).where(comp_reg_competitions: { admin_user_id: user.id }).select(:id).to_sql
      where("id IN ((#{person_sql}) UNION (#{competition_sql}))")
    end

    validates :first_name, :last_name, :gender, :competition, :admin_user, presence: true

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
