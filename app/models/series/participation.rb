class Series::Participation < ApplicationRecord
  include Firesport::TimeInvalid

  belongs_to :cup, class_name: 'Series::Cup'
  belongs_to :assessment, class_name: 'Series::Assessment'

  validates :cup, :assessment, :time, :points, :rank, presence: true
end
