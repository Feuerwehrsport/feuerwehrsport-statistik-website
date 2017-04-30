class Import::Series
  include ActiveModel::Model
  attr_accessor :competition_id, :selected_entities, :series_round_id, :perform_now, :second_run
  attr_reader :assessment_configs, :cup

  def initialize(*args)
    super(*args)
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

  def person_assessment_disciplines
    person_class.try(:assessment_disciplines) || {}
  end

  def team_assessment_disciplines
    team_class.try(:assessment_disciplines) || {}
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

  def group_assessment_disciplines
    team_class.try(:group_assessment_disciplines) || {}
  end

  def run
    # valid?
    configure_assessments

    if selected_entities.is_a? Hash
      selected_entities.each do |key, entities|
        find_assessment_config(key).selected_entities = (entities.select { |k, v| v == "1" }.keys)
      end
    end


    create_cup
    [:person, :team, :group].each do |type|
      send("#{type}_assessment_disciplines").each do |discipline, names|
        names.each do |name|
          [:female, :male].each do |gender|
            scores = series_participations(type, gender, discipline)
            next unless scores.present?
            scores = exclude_scores(scores, type, gender, name)
            if scores.present?
              assessment = create_or_find_assessment(type, discipline, gender, name)
              create_participations(assessment, cup, scores, send("#{type}_class"))
            end
          end
        end
      end
    end
  end

  def round
    ::Series::Round.find(series_round_id)
  end

  def competition
    Competition.find(competition_id)
  end

  protected

  def exclude_scores(scores, type, gender, name)
    if type.in?([:team, :group])
      selected_teams = find_assessment_config("#{gender}-team").selected_entities.map do |key, name, selected|
        key.split("-")
      end
      scores = scores.select do |score|
        [score.team_id.to_s, score.team_number.to_s].in?(selected_teams)
      end
      scores
    else
      selected_people = find_assessment_config("#{gender}-person#{name}").selected_entities.map do |key, name, selected|
        key
      end
      scores.select { |score| score.person_id.to_s.in?(selected_people) }
    end
  end

  def add_assessment_config(id, entities, &block)
    @assessment_configs.push(AssessmentConfig.new(id.to_s, entities.deep_dup, block))
  end

  def find_assessment_config(id)
    @assessment_configs.find { |assessment_config| assessment_config.id == id.to_s }
  end

  def create_cup
    @cup = ::Series::Cup.create!(round: round, competition_id: competition_id)
  end


  def configure_assessments
    @assessment_configs = []
    [:female, :male].each do |gender|
      group_teams = competition.group_assessment(group_assessment_disciplines.keys, gender).map {|ga| [ga.team.id, ga.team_number]}
      team_teams  = competition.group_scores.gender(gender).pluck(:team_id, :team_number)
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
      type: type != :person ? "Series::TeamAssessment" : "Series::PersonAssessment",
      round: round,
      discipline: discipline, 
      gender: Genderable::GENDERS[gender],
      name: name,
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
      if discipline.to_sym == :zk
        competition.score_double_events.gender(gender).sort_by(&:time)
      else
        competition.scores.no_finals.gender(gender).discipline(discipline).best_of_competition.sort_by(&:time)
      end
    end
  end

  def create_participations(assessment, cup, scores, klass)
    rank = 1
    scores.each do |score|
      hash = {
        assessment: assessment, 
        cup: cup, 
        time: score.time, 
        points: klass.points_for_result(rank, score.time), 
        rank: rank
      }
      if score.is_a?(GroupScore) || score.is_a?(Calculation::CompetitionGroupAssessment)
        ::Series::TeamParticipation.create!(hash.merge(team: score.team, team_number: score.team_number))
      else
        ::Series::PersonParticipation.create!(hash.merge(person: score.person))
      end
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
