# frozen_string_literal: true

class Registrations::Team < ApplicationRecord
  include Genderable
  include Taggable
  belongs_to :band, class_name: 'Registrations::Band'
  belongs_to :admin_user

  delegate :competition, to: :band

  has_many :team_assessment_participations, inverse_of: :team, dependent: :destroy,
                                            class_name: 'Registrations::TeamAssessmentParticipation'
  has_many :assessments, through: :team_assessment_participations, class_name: 'Registrations::Assessment'
  has_many :people, inverse_of: :team, dependent: :destroy, class_name: 'Registrations::Person'

  validates :email_address, 'valid_email_2/email': true, allow_blank: true

  accepts_nested_attributes_for :team_assessment_participations, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :people, reject_if: :all_blank, allow_destroy: true

  default_scope -> { order(:name, :team_number) }
  scope :manageable_by, ->(user) do
    team_sql = Registrations::Team.unscoped.joins(band: :competition).merge(Registrations::Competition.open)
                                  .where(admin_user_id: user.id).select(:id).to_sql
    competition_sql = Registrations::Team.unscoped.joins(band: :competition)
                                         .where(registrations_competitions: { admin_user_id: user.id }).select(:id)
                                         .to_sql
    where("id IN ((#{team_sql}) UNION (#{competition_sql}))")
  end
end
