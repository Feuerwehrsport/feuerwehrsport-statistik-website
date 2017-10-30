class Series::Cup < ActiveRecord::Base
  include Series::Participationable

  belongs_to :round, class_name: 'Series::Round'
  belongs_to :competition, class_name: 'Competition'
  has_many :assessments, through: :round, class_name: 'Series::Assessment'
  has_many :participations, dependent: :destroy, class_name: 'Series::Participation'

  default_scope -> { joins(:competition).order('competitions.date') }

  validates :round, :competition, presence: true
end
