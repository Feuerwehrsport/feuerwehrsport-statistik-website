class ScoreType < ActiveRecord::Base
  has_many :competitions, dependent: :restrict_with_exception

  validates :people, :run, :score, presence: true
end
