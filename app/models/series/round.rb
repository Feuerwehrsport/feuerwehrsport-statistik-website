module Series
  class Round < ActiveRecord::Base
    has_many :cups 
    has_many :assessments 

    validates :name, :year, presence: true

    scope :cup_count, -> do
      select("#{table_name}.*, COUNT(#{Cup.table_name}.id) AS cup_count").
      joins(:cups).
      group("#{table_name}.id")
    end


    def disciplines
      assessments.pluck(:discipline).uniq.sort
    end

    def team_count
      TeamParticipation.where(assessment: assessments).pluck(:team_id).uniq.count
    end

    def person_count
      PersonParticipation.where(assessment: assessments).pluck(:person_id).uniq.count
    end
  end
end
