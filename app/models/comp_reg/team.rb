module CompReg
  class Team < ActiveRecord::Base
    include Genderable
    belongs_to :competition

    validates :competition, presence: true
  end
end
