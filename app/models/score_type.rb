class ScoreType < ActiveRecord::Base
  has_many :competitions, dependent: :restrict_with_exception

  scope :filter_collection, -> { order(:people, :run, :score) }

  validates :people, :run, :score, presence: true
end
