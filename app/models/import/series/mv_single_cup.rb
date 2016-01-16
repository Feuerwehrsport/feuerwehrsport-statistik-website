module Import
  module Series
    class MVSingleCup < Base

      protected

      def points
        {
          person: 20,
        }
      end

      def configure_assessments
        [:female, :male].each do |gender|
          person_ids = competition.scores.gender(gender).discipline(assessment_disciplines.keys.first).pluck(:person_id).uniq
          people = Person.where(id: person_ids).order(:last_name, :first_name).decorate.map do |person|
            [person.id.to_s, person.full_name, true]
          end
          add_assessment_config(gender, people)
        end
      end

      def exclude_scores(scores, assessment)
        selected_people = find_assessment_config(assessment.gender).selected_entities.map do |key, name, selected|
          key
        end
        scores.select { |score| score.person_id.to_s.in?(selected_people) }
      end
    end
  end
end