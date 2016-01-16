module Import
  module Series
    class MVCup < Base

      protected

      def assessment_disciplines
        {
          person: {},
          team: { la: [""] },
          group: {},
        }
      end

      def points
        {
          team: 20,
        }
      end

      def configure_assessments
        [:female, :male].each do |gender|
          teams = competition.group_scores.gender(gender).pluck(:team_id, :team_number).uniq.map do |team_id, team_number|
            ["#{team_id}-#{team_number}", "#{Team.find(team_id).name} #{team_number+1}", true]
          end
          add_assessment_config(gender, teams)
        end
      end

      def exclude_scores(scores, assessment)
        selected_teams = find_assessment_config(assessment.gender).selected_entities.map do |key, name, selected|
          key.split("-")
        end
        scores = scores.select do |score|
          [score.team_id.to_s, score.team_number.to_s].in?(selected_teams)
        end
        scores
      end
    end
  end
end