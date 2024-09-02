# frozen_string_literal: true

class Appointment < ApplicationRecord
  include UrlSupport

  belongs_to :event
  belongs_to :creator, polymorphic: true
  has_many :links, as: :linkable, dependent: :restrict_with_exception

  default_scope -> { order(:dated_at) }
  scope :upcoming, -> { where('dated_at >= ?', 1.week.ago) }
  scope :dashboard, -> { where('dated_at >= ?', 1.day.ago).limit(6) }
  scope :event, ->(event_id) { where(event_id:) }

  validates :dated_at, :name, :description, presence: true
  attr_accessor :updateable

  def discipline_array
    disciplines.split(',')
  end

  def disciplines
    super.downcase
  end
end
