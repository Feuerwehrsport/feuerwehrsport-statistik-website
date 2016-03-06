module Import
  module Series
    class LaBase < Base

      protected

      def assessment_disciplines
        {
          person: {},
          team: { la: [""] },
          group: {},
        }
      end

      def configure_assessments
        [:female, :male].each do |gender|
          teams = competition.group_scores.gender(gender).pluck(:team_id, :team_number).uniq.map do |team_id, team_number|
            ["#{team_id}-#{team_number}", "#{Team.find(team_id).name} #{team_number+1}", true]
          end
          add_assessment_config(gender, teams)
        end
        categories = competition.group_score_categories.map do |group_score_category|
          [group_score_category.id.to_s, group_score_category.decorate, true]
        end
        add_assessment_config("group_score_categories", categories)
      end

      def exclude_scores(scores, assessment)
        selected_teams = find_assessment_config(assessment.gender).selected_entities.map do |key, name, selected|
          key.split("-")
        end
        scores = scores.select do |score|
          [score.team_id.to_s, score.team_number.to_s].in?(selected_teams)
        end

        category_ids = find_assessment_config("group_score_categories").selected_entities.map(&:first)
        scores = scores.select { |score| score.group_score_category_id.to_s.in?(category_ids) }
        scores
      end
    end
  end
end