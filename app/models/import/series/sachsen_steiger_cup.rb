module Import
  module Series
    class SachsenSteigerCup < Base

      protected

      def points
        {
          person: 30,
          group: 10,
        }
      end

      def assessment_disciplines
        {
          person: { hl: [""] },
          team: { },
          group: { hl: [""] },
        }
      end

      def configure_assessments
        [:male].each do |gender|
          group_teams = competition.group_assessment([:hl, :hb], gender).map {|ga| [ga.team.id, ga.team_number]}
          team_teams  = competition.group_scores.gender(gender).pluck(:team_id, :team_number)

          teams = (group_teams + team_teams).uniq.map do |team_id, team_number|
            ["#{team_id}-#{team_number}", "#{Team.find(team_id).name} #{team_number}", true]
          end
          add_assessment_config("#{gender}-team", teams)

          person_ids = competition.scores.gender(gender).pluck(:person_id).uniq
          people = Person.where(id: person_ids).order(:last_name, :first_name).decorate.map do |person|
            [person.id.to_s, person.full_name, true]
          end
          add_assessment_config("#{gender}-single", people)
        end
      end

      def exclude_scores(scores, assessment)
        if assessment.is_a?(::Series::TeamAssessment)
          selected_teams = find_assessment_config("#{assessment.gender}-team").selected_entities.map do |key, name, selected|
            key.split("-")
          end
          scores = scores.select do |score|
            [score.team_id.to_s, score.team_number.to_s].in?(selected_teams)
          end
          scores
        else
          selected_people = find_assessment_config("#{assessment.gender}-single").selected_entities.map do |key, name, selected|
            key
          end
          scores.select { |score| score.person_id.to_s.in?(selected_people) }
        end
      end
    end
  end
end