# frozen_string_literal: true

class Appointment < ApplicationRecord
  include URLSupport

  belongs_to :event
  belongs_to :creator, polymorphic: true
  has_many :links, as: :linkable, dependent: :restrict_with_exception

  default_scope -> { order(:dated_at) }
  scope :upcoming, -> { where('dated_at >= ?', 1.week.ago) }
  scope :event, ->(event_id) { where(event_id: event_id) }

  validates :dated_at, :name, :description, presence: true
  attr_accessor :updateable

  def discipline_array
    disciplines.split(',')
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
    e.location = place if place.present?
    e.created = created_at
    e.last_modified = updated_at
    e.uid = e.url = appointment_url(self)
    e
  end
end
