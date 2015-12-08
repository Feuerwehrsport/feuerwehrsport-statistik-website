class Appointment < ActiveRecord::Base
  belongs_to :place
  belongs_to :event
  has_many :links, as: :linkable, dependent: :restrict_with_exception

  default_scope -> { order(:dated_at) }
  scope :upcoming, -> { where("dated_at >= ?", 1.weeks.ago) }

  validates :dated_at, :name, :description, :disciplines, presence: true

  def discipline_array
    disciplines.split(",").map(&:downcase)
  end
end
