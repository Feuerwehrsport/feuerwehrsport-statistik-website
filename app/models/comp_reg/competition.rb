module CompReg
  class Competition < ActiveRecord::Base
    belongs_to :admin_user
    has_many :competition_assessments, inverse_of: :competition, dependent: :destroy
    has_many :teams, dependent: :destroy
    has_many :people, dependent: :destroy

    validates :date, :description, :name, :admin_user, :place, presence: true

    accepts_nested_attributes_for :competition_assessments, reject_if: :all_blank, allow_destroy: true

    scope :open, -> do
      where("date >= ?", Date.today).
      where("open_at IS NULL OR open_at <= ?", Time.now).
      where("close_at IS NULL OR close_at >= ?", Time.now)
    end

    def person_tag_list
      person_tags.split(',').each(&:strip!)
    end

    def team_tag_list
      team_tags.split(',').each(&:strip!)
    end
  end
end
