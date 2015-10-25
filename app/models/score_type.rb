class ScoreType < ActiveRecord::Base
  has_many :competitions

  validates :people, :run, :score, presence: true
end
