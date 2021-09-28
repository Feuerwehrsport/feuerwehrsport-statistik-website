class Ipo::Registration < ApplicationRecord
  DATE = Date.new(2018, 9, 22)
  REGISTRATION_OPEN = Time.zone.local(2018, 3, 3, 12, 0, 0)
  REGISTRATION_CLOSE = Time.zone.local(2018, 3, 17, 12, 0, 0)

  attr_accessor :confirm_inform_consent
  validates :email_address, "valid_email_2/email": true
  validates :terms_of_service, acceptance: { accept: true }
  validate do
    unless [youth_team, female_team, male_team].any?
      errors.add(:youth_team, :at_least_one_type)
      errors.add(:female_team, :at_least_one_type)
      errors.add(:male_team, :at_least_one_type)
    end
  end

  scope :female_team, -> { where(female_team: true) }
  scope :male_team, -> { where(male_team: true) }
  scope :youth_team, -> { where(youth_team: true) }
end
