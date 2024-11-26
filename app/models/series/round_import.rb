# frozen_string_literal: true

class Series::RoundImport
  include M3::FormObject

  belongs_to :round
  belongs_to :competition
  belongs_to :cup
  boolean_accessor :import_now
  attr_accessor :selected_entities
  attr_reader :assessment_configs

  def save
    configure_assessments

    if selected_entities.is_a? Hash
      selected_entities.each do |key, entities|
        find_assessment_config(key).selected_entities = entities.select { |_k, v| v == '1' }.keys
      end
    end

    create_cup
    %i[person team group].each do |type|
      send(:"#{type}_assessment_disciplines").each do |discipline, names|
        names.each do |name|
          Genderable::GENDERS.each_key do |gender|
            scores = series_participations(type, gender, discipline)
            next if scores.blank?

            scores = exclude_scores(scores, type, gender, name)
            if scores.present?
              assessment = create_or_find_assessment(type, discipline, gender, name)
              create_participations(assessment, cup, scores, send(:"#{type}_class"))
            end
          end
        end
      end
    end
  end

  protected

  def exclude_scores(scores, type, gender, name)
    if type.in?(%i[team group])
      selected_teams = find_assessment_config("#{gender}-team").selected_entities.map do |key, _name, _selected|
        key.split('-')
      end
      scores = scores.select do |score|
        [score.team_id.to_s, score.team_number.to_s].in?(selected_teams)
      end
    end
    if type == :team
      selected_categories = find_assessment_config('categories').selected_entities.map { |key, _name, _selected| key }
      scores = scores.select do |score|
        score.group_score_category_id.to_s.in?(selected_categories)
      end
    end
    if type == :person
      selected_people = find_assessment_config("#{gender}-person#{name}")
                        .selected_entities.map { |key, _name, _selected| key }
      scores = scores.select { |score| score.person_id.to_s.in?(selected_people) }
    end
    scores
  end

  def add_assessment_config(id, entities, &block)
    @assessment_configs.push(AssessmentConfig.new(id.to_s, entities.deep_dup, block))
  end

  def find_assessment_config(id)
    @assessment_configs.find { |assessment_config| assessment_config.id == id.to_s }
  end

  def create_cup
    @cup = Series::Cup.create!(round:, competition_id:)
  end

  def configure_assessments
    @assessment_configs = []
    add_assessment_config(
      'categories',
      competition.group_score_categories.map { |c| [c.id.to_s, "#{c.name} #{c.group_score_type.name}", true] },
    )

    Genderable::GENDER_KEYS.each do |gender|
      group_teams = competition.group_assessment(group_assessment_disciplines.keys, gender)
                               .map { |ga| [ga.team.id, ga.team_number] }
      team_teams = competition.group_scores.gender(gender).pluck(:team_id, :team_number)
      teams = (group_teams + team_teams).uniq.map do |team_id, team_number|
        ["#{team_id}-#{team_number}", "#{Team.find(team_id).name} #{team_number}", true]
      end
      add_assessment_config("#{gender}-team", teams) if teams.present?

      person_ids = competition.scores.gender(gender).pluck(:person_id).uniq
      people = Person.where(id: person_ids).order(:last_name, :first_name).decorate.map do |person|
        [person.id.to_s, person.full_name, true]
      end
      person_assessment_disciplines.values.flatten.uniq.each do |assessment_name|
        add_assessment_config("#{gender}-person#{assessment_name}", people) if people.present?
      end
    end
  end

  def create_or_find_assessment(type, discipline, gender, name)
    ::Series::Assessment.find_or_create_by!(
      type: type == :person ? 'Series::PersonAssessment' : 'Series::TeamAssessment',
      round:,
      discipline:,
      gender: Genderable::GENDERS[gender],
      name:,
    )
  end

  def series_participations(type, gender, discipline)
    case type
    when :team
      scores = competition.group_scores.gender(gender).discipline(discipline).best_of_competition(true)
      scores.sort
    when :group
      competition.group_assessment(discipline, gender)
    when :person
      case discipline.to_sym
      when :zk
        competition.score_double_events.gender(gender).sort_by(&:time)
      when :zw
        competition.score_low_double_events.gender(gender).sort_by(&:time)
      else
        competition.scores.no_finals.gender(gender).discipline(discipline).best_of_competition.sort_by(&:time)
      end
    end
  end

  def create_participations(assessment, cup, scores, klass)
    rank = 1
    scores.each do |score|
      hash = {
        assessment:,
        cup:,
        time: score.time,
        points: klass.points_for_result(rank, score.time, cup.round, gender: assessment.gender),
        rank:,
      }
      if score.is_a?(GroupScore) || score.is_a?(Calculation::CompetitionGroupAssessment)
        ::Series::TeamParticipation.create!(hash.merge(team: score.team, team_number: score.team_number))
      else
        ::Series::PersonParticipation.create!(hash.merge(person: score.person))
      end
      rank += 1
    end
  end

  AssessmentConfig = Struct.new(:id, :entities, :block, :selected_entities) do
    def selected_entities=(new_entities)
      self.entities = entities.map do |entity|
        entity[2] = entity.first.in?(new_entities)
        entity
      end
    end

    def selected_entities
      entities.select { |entity| entity[2] }
    end
  end

  def person_class
    @person_class ||= Firesport::Series::Handler.person_class_for(round.aggregate_type)
  end

  def team_class
    @team_class ||= Firesport::Series::Handler.team_class_for(round.aggregate_type)
  end

  def group_class
    team_class
  end

  def group_assessment_disciplines
    team_class.try(:group_assessment_disciplines) || {}
  end

  def person_assessment_disciplines
    person_class.try(:assessment_disciplines) || {}
  end

  def team_assessment_disciplines
    team_class.try(:assessment_disciplines) || {}
  end
end
