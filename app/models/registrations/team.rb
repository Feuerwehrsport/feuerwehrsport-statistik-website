class Registrations::Team < ApplicationRecord
  include Genderable
  include Taggable
  belongs_to :competition, class_name: 'Registrations::Competition'
  belongs_to :admin_user
  belongs_to :federal_state
  has_many :team_assessment_participations, inverse_of: :team, dependent: :destroy,
                                            class_name: 'Registrations::TeamAssessmentParticipation'
  has_many :assessments, through: :team_assessment_participations, class_name: 'Registrations::Assessment'
  has_many :people, inverse_of: :team, dependent: :destroy, class_name: 'Registrations::Person'

  validates :competition, :name, :gender, :shortcut, :admin_user, presence: true
  validates :email_address, "valid_email_2/email": true, allow_blank: true

  accepts_nested_attributes_for :team_assessment_participations, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :people, reject_if: :all_blank, allow_destroy: true

  default_scope -> { order(:name, :team_number) }
  scope :manageable_by, ->(user) do
    team_sql = Registrations::Team.joins(:competition).merge(Registrations::Competition.open)
                                  .where(admin_user_id: user.id).select(:id).to_sql
    competition_sql = Registrations::Team.joins(:competition)
                                         .where(registrations_competitions: { admin_user_id: user.id }).select(:id)
                                         .to_sql
    where("id IN ((#{team_sql}) UNION (#{competition_sql}))")
  end

  def self.build_from_last(attributes)
    last_registration = where(attributes).order(:updated_at).last
    if last_registration.present?
      attributes.merge!(last_registration.slice(
                          'team_leader',
                          'street_with_house_number',
                          'postal_code',
                          'locality',
                          'phone_number',
                          'email_address',
                        ))
    end
    new(attributes)
  end
end
