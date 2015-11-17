module Series
  class Round < ActiveRecord::Base
    has_many :cups 
    has_many :assessments 

    validates :name, :year, presence: true

    default_scope -> { order(year: :desc, name: :asc) }

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

    def team_assessment_rows(gender)
      @team_assessment_rows ||= calculate_rows
      @team_assessment_rows[gender]
    end

    def aggregate_class
      aggregate_type = "MVCup"
      @aggregate_class ||= "Series::TeamAssessmentRows::#{aggregate_type}".constantize
    end

    protected

    def calculate_rows
      rows = {}
      [:female, :male].each do |gender|
        rows[gender] = teams(gender).values.sort
      end
      rows
    end

    def teams(gender)
      teams = {}
      TeamParticipation.where(assessment: assessments.gender(gender)).each do |participation|
        teams[participation.entity_id] ||= aggregate_class.new(participation.team, participation.team_number)
        teams[participation.entity_id].add_participation(participation)
      end
      teams
    end
  end
end
