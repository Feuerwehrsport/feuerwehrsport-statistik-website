module Import
  module Series
    class Base
      TYPES = [
        "DCup",
        "MVCup",
        "MVHindernisCup",
        "MVSteigerCup",
        "SachsenSteigerCup",
      ]
      include ActiveModel::Model
      attr_accessor :competition_id, :series_type, :selected_entities, :series_round_id, :perform_now, :second_run
      attr_reader :assessment_configs, :cup

      def initialize(*args)
        super(*args)
        @assessment_configs = []

        configure_assessments

        if selected_entities.is_a? Hash
          selected_entities.each do |key, entities|
            find_assessment_config(key).selected_entities = (entities.select { |k, v| v == "1" }.keys)
          end
        end

        perform if series_round_id.present? && competition_id.present?
      end

      def round
        ::Series::Round.find(series_round_id)
      end

      def competition
        Competition.find(competition_id)
      end

      protected

      def add_assessment_config(id, entities, &block)
        @assessment_configs.push(AssessmentConfig.new(id.to_s, entities, block))
      end

      def find_assessment_config(id)
        @assessment_configs.find { |assessment_config| assessment_config.id == id.to_s }
      end

      def create_cup
        @cup = ::Series::Cup.create!(round: round, competition_id: competition_id)
      end

      def configure_assessments
      end

      def create_or_find_assessment(type, discipline, gender, name)
        ::Series::Assessment.find_or_create_by!(
          type: type != :person ? "Series::TeamAssessment" : "Series::PersonAssessment",
          round: round,
          discipline: discipline, 
          gender: Genderable::GENDERS[gender],
          name: name,
        )
      end

      def perform
        create_cup
        [:person, :team, :group].each do |type|
          assessment_disciplines[type].each do |discipline, names|
            names.each do |name|
              [:female, :male].each do |gender|
                scores = series_participations(type, gender, discipline)
                next unless scores.present?
                assessment = create_or_find_assessment(type, discipline, gender, name)
                scores = exclude_scores(scores, assessment)
                create_participations(assessment, cup, scores, points[type])
              end
            end
          end
        end
      end

      def series_participations(type, gender, discipline)
        case type
        when :team
          scores = competition.group_scores.gender(gender).discipline(discipline).best_of_competition(true)
          scores.sort
        when :group
          competition.group_assessment(discipline, gender)
        when :person
          if discipline.to_sym == :zk
            competition.scores.no_finals.gender(gender).discipline(discipline).best_of_competition.sort_by(&:time)
          else
            competition.score_double_events.gender(gender).sort_by(&:time)
          end
        end
      end
  
      def create_participations(assessment, cup, scores, points)
        rank = 1
        scores.each do |score|
          hash = {
            assessment: assessment, 
            cup: cup, 
            time: score.time, 
            points: points, 
            rank: rank
          }
          if score.is_a?(GroupScore)
            ::Series::TeamParticipation.create!(hash.merge(team: score.team, team_number: score.team_number))
          else
            ::Series::PersonParticipation.create!(hash.merge(person: score.person))
          end
          points -= 1 if points > 0
          rank += 1
        end
      end


      class AssessmentConfig < Struct.new(:id, :entities, :block, :selected_entities)
        def selected_entities= new_entities
          self.entities = entities.map do |entity|
            entity[2] = entity.first.in?(new_entities)
            entity
          end
        end

        def selected_entities
          entities.select { |entity| entity[2] }
        end
      end
    end
  end
end
