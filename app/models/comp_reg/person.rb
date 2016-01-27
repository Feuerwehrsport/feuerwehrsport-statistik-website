module CompReg
  class Person < ActiveRecord::Base
    include Genderable
    belongs_to :competition
    belongs_to :team

    validates :competition, presence: true
  end
end
