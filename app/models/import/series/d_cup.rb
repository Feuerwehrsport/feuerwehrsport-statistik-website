module Import
  module Series
    class DCup < Base

      protected

      def assessment_disciplines
        {
          person: { hb: ["", "U20"], hl: ["", "U20"], zk: ["", "U20"] },
          team: { la: [""], fs: [""], gs: [""] },
          group: { hb: [""], hl: [""] },
        }
      end

      def points
        {
          team: 10,
          person: 30,
          group: 10,
        }
      end

      def configure_assessments
        [:female, :male].each do |gender|
          teams = competition.group_scores.gender(gender).pluck(:team_id, :team_number).uniq.map do |team_id, team_number|
            ["#{team_id}-#{team_number}", "#{Team.find(team_id).name} #{team_number+1}", true]
          end
          add_assessment_config("#{gender}-team", teams)

          person_ids = competition.scores.gender(gender).pluck(:person_id).uniq
          people = Person.where(id: person_ids).order(:last_name, :first_name).decorate.map do |person|
            [person.id.to_s, person.full_name, true]
          end
          add_assessment_config("#{gender}-single", people)
          add_assessment_config("#{gender}-singleU20", people)
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
          selected_people = find_assessment_config("#{assessment.gender}-single#{assessment.name}").selected_entities.map do |key, name, selected|
            key
          end
          scores.select { |score| score.person_id.to_s.in?(selected_people) }
        end
      end
    end
  end
end