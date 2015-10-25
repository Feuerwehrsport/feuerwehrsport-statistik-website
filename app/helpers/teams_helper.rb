module TeamsHelper
  def states_hash
    hash = Team.group(:state).count
    other = hash.values.select { |c| c <= 50 }.sum
    hash = hash.select { |k, v| v > 50 }
    hash["Andere"] = other
    hash
  end
end