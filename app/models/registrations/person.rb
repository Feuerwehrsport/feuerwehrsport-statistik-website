# frozen_string_literal: true

class Registrations::Person < ApplicationRecord
  include Genderable
  include Taggable
  belongs_to :admin_user
  belongs_to :competition, class_name: 'Registrations::Competition'
  belongs_to :team, class_name: 'Registrations::Team'
  has_many :person_assessment_participations, inverse_of: :person, dependent: :destroy,
                                              class_name: 'Registrations::PersonAssessmentParticipation'
  has_many :assessments, through: :person_assessment_participations,
                         class_name: 'Registrations::Assessment'

  default_scope -> { order(:competition_id, :team_id, :registration_order) }
  scope :with_assessment, ->(assessment) do
    joins(:assessments)
      .where(registrations_assessments: { id: assessment })
  end
  scope :manageable_by, ->(user) do
    person_sql = Registrations::Person.unscoped.joins(:competition)
                                      .merge(Registrations::Competition.open)
                                      .where(admin_user_id: user.id)
                                      .select(:id).to_sql
    competition_sql = Registrations::Person.unscoped.joins(:competition)
                                           .where(registrations_competitions: { admin_user_id: user.id })
                                           .select(:id).to_sql
    where("id IN ((#{person_sql}) UNION (#{competition_sql}))")
  end
  scope :without_team, -> { where(team_id: nil) }

  validates :first_name, :last_name, :gender, presence: true
  validate :validate_team_gender

  accepts_nested_attributes_for :person_assessment_participations, reject_if: :all_blank, allow_destroy: true

  before_validation do
    self.gender = team.gender if team.present? && gender.nil?
    self.competition = team.competition if team.present? && competition.nil?
  end
  before_save do
    if registration_order.zero? && team.present?
      self.registration_order = (team.people.maximum(:registration_order) || 0) + 1
    end
  end

  def gender
    super || team.try(:gender)
  end

  def competition_id
    super || team.try(:competition_id)
  end

  private

  def validate_team_gender
    errors.add(:gender, :invalid) if team.present? && team.gender != gender
  end
end
