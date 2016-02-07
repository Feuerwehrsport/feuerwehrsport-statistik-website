module CompReg
  class Competition < ActiveRecord::Base
    belongs_to :admin_user
    has_many :competition_assessments, inverse_of: :competition
    has_many :teams
    has_many :people

    validates :date, :description, :name, :admin_user, :place, presence: true

    accepts_nested_attributes_for :competition_assessments, reject_if: :all_blank, allow_destroy: true
  end
end
