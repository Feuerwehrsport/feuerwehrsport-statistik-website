module CompReg
  class Competition < ActiveRecord::Base
    belongs_to :admin_user
    has_many :competition_assessments
    has_many :teams
    has_many :people

    validates :date, :admin_user, :place, presence: true
  end
end
