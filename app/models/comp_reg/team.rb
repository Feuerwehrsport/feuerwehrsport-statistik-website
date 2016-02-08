module CompReg
  class Team < ActiveRecord::Base
    include Genderable
    belongs_to :competition
    belongs_to :admin_user
    has_many :team_assessment_participations, inverse_of: :team
    has_many :competition_assessments, through: :team_assessment_participations
    has_many :people, inverse_of: :team

    validates :competition, :name, :gender, :shortcut, presence: true
    validates :email_address, email_format: true, allow_blank: true

    accepts_nested_attributes_for :team_assessment_participations, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :people, reject_if: :all_blank, allow_destroy: true
  end
end
