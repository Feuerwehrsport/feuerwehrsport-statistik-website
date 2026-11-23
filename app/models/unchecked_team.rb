# frozen_string_literal: true

class UncheckedTeam < Team
  default_scope { unchecked.reorder(id: :desc) }

  def duplicate_candidates
    team_duplicates.candidates
  end

  # places of the competitions (with position) for the distances of the nominatim results
  delegate :competition_places, to: :team_duplicates

  private

  def team_duplicates
    @team_duplicates ||= TeamDuplicates.new(self)
  end
end
