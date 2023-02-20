# frozen_string_literal: true

class Registrations::Mail
  include M3::FormObject

  attr_accessor :subject, :text

  belongs_to :competition, class_name: 'Registrations::Competition'
  belongs_to :admin_user, class_name: 'AdminUser'
  boolean_accessor :add_registration_file

  validates :subject, :text, presence: true

  delegate :teams, to: :competition

  def people
    competition.people.without_team
  end

  def save
    valid?
  end
end
