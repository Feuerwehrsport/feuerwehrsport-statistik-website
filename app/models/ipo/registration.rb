class Ipo::Registration < ActiveRecord::Base
  attr_accessor :confirm_inform_consent
  validates :email_address, email_format: true
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
