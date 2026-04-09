# frozen_string_literal: true

class Series::AssessmentCalculation
  attr_reader :config

  delegate :entity_key, :key, :round, :round_key, :points_for_rank, :sort, :ranking_logic, :honor_ranking_logic,
           :min_participations_count, to: :config
  delegate :cups, :team_assessments, :person_assessments, :full_cup_count, to: :round

  def initialize(config)
    @config = config
  end

  def rows
    @rows ||= begin
      # Sortieren nach Config
      rows = entities.values.sort

      # Plätze vergeben
      calculate_ranks!(rows)

      # Besondere Beachtung der ersten drei Plätze und erneut vergeben
      if honor_ranking_logic.present?
        honor_rows = rows.select { |row| row.rank.present? && row.rank <= 3 }
                         .sort { |row, other| sort(row, other, logic_array: honor_ranking_logic) }
        calculate_ranks!(honor_rows, logic_array: honor_ranking_logic)
        rows.sort! { |row, other| sort(row, other, with_rank: true) }
      end
      rows
    end
  end

  protected

  def completed?
    @completed ||= full_cup_count == cups.count
  end

  def calculate_ranks!(rows, logic_array: ranking_logic)
    current_rank = 1
    last_row = nil
    rank = 1

    rows.each do |row|
      if completed? && row.participation_count < min_participations_count
        row.rank = nil
        next
      end

      current_rank = rank unless last_row && sort(row, last_row, logic_array:).zero?
      row.rank = current_rank

      last_row = row
      rank += 1
    end

    rows
  end

  def entities
    entity_key == :team ? teams : people
  end

  def people
    people = {}

    # Online-Einträge hinzufügen
    Series::PersonParticipation.where(person_assessment: person_assessments.where(key:)).find_each do |participation|
      people[participation.person_id] ||= Series::Person.new(
        config:, person: participation.person, round:,
      )
      people[participation.person_id].add_participation(participation)
    end

    people
  end

  def teams
    teams = {}

    # Online-Einträge hinzufügen
    Series::TeamParticipation.where(team_assessment: team_assessments.where(key:)).find_each do |participation|
      teams[participation.entity_id] ||= Series::Team.new(
        config:, team: participation.team, team_number: participation.team_number,
        team_gender: participation.team_gender, round:
      )
      teams[participation.entity_id].add_participation(participation)
    end

    teams
  end
end
