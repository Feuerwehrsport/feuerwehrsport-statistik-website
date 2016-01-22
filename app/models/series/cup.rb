module Series
  class Cup < ActiveRecord::Base
    include Participationable

    belongs_to :round
    belongs_to :competition
    has_many :assessments, through: :round
    has_many :participations, dependent: :destroy

    default_scope -> { joins(:competition).order("competitions.date")}

    validates :round, :competition, presence: true
  end
end
