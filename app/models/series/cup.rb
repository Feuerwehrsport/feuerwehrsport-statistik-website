module Series
  class Cup < ActiveRecord::Base
    belongs_to :round
    belongs_to :competition
    has_many :assessments, through: :round
    has_many :participations

    validates :round, :competition, presence: true
  end
end
