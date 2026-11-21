# frozen_string_literal: true

# scores of an import that already exist in the competition: same person (single disciplines) or same team,
# team number and gender (group disciplines) with the same time
class Import::Duplicates
  def initialize(competition_id:, discipline:, gender:)
    @competition_id = competition_id
    @discipline = discipline.to_s
    @gender = gender.to_s
  end

  # times of the score (hash like in Import::Scores) that are already present
  def times(score)
    key = group? ? [score[:team_id].presence&.to_i, score[:team_number].to_i] : [score[:person_id].presence&.to_i]
    return [] if key.first.nil?

    Array(score[:times]).map(&:to_i).select { existing.include?([*key, it]) }
  end

  def any?(scores)
    scores.any? { times(it).any? }
  end

  private

  def group?
    Discipline.group?(@discipline)
  end

  def existing
    @existing ||= Set.new(group? ? existing_group_scores : existing_scores)
  end

  def existing_scores
    Score.joins(:single_discipline).where(competition_id: @competition_id, single_disciplines: { key: @discipline })
         .pluck(:person_id, :time)
  end

  def existing_group_scores
    GroupScore.discipline(@discipline).gender(@gender)
              .where(group_score_categories: { competition_id: @competition_id })
              .pluck(:team_id, :team_number, :time)
  end
end
