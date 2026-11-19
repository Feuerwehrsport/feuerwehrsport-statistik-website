# frozen_string_literal: true

class UncheckedTeam < Team
  default_scope { unchecked.reorder(id: :desc) }

  def duplicate_candidates
    @duplicate_candidates ||= TeamDuplicates.new(self).candidates
  end
end
