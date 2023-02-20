# frozen_string_literal: true
class UncheckedTeam < Team
  default_scope { unchecked.reorder(id: :desc) }

  def similar_teams
    @similar_teams ||= Team.where('LEVENSHTEIN(teams.shortcut, ?) < 3', shortcut).where.not(id: id)
  end
end
