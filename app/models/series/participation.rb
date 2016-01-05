module Series
  class Participation < ActiveRecord::Base
    include TimeInvalid

    belongs_to :cup
    belongs_to :assessment

    validates :cup, :assessment, :time, :points, :rank, presence: true
  end
end
