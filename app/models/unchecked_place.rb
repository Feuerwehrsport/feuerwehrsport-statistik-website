# frozen_string_literal: true

# places to check (list "Neue Wettkampforte"): duplicates, position
class UncheckedPlace < Place
  default_scope { unchecked.reorder(id: :desc) }

  def duplicate_candidates
    @duplicate_candidates ||= PlaceDuplicates.new(self).candidates
  end
end
