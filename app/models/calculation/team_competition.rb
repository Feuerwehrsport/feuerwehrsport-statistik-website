class Calculation::TeamCompetition < Competition
  attr_reader :hl, :hb, :gs, :fs, :la

  def increment(discipline, by=1)
    value = instance_variable_get(:"@#{discipline}") || 0
    instance_variable_set(:"@#{discipline}", value + by)
  end
end