require 'icalendar'

class Appointment < ActiveRecord::Base
  belongs_to :place
  belongs_to :event
  belongs_to :creator, polymorphic: true
  has_many :links, as: :linkable, dependent: :restrict_with_exception

  default_scope -> { order(:dated_at) }
  scope :upcoming, -> { where("dated_at >= ?", 1.weeks.ago) }

  validates :dated_at, :name, :description, presence: true

  def discipline_array
    disciplines.split(",")
  end

  def disciplines
    super.downcase
  end

  def to_icalendar_event
    e = Icalendar::Event.new
    e.dtstart = dated_at
    e.summary = name
    e.summary += " - #{event.name}" if event.present?
    e.description = description
    e.location = place.name if place.present?
    e.created = created_at
    e.last_modified = updated_at
    e.uid = e.url = Rails.application.routes.url_helpers.appointment_url(self, Rails.configuration.action_controller.default_url_options)
    e
  end
end
