# frozen_string_literal: true

# fastest time in the database per discipline and gender (start page)
class Calc::DisciplineBests < Calc::Base
  DISCIPLINES = {
    hl: %i[female male],
    hb: %i[female male],
    gs: %i[female],
    fs: %i[female male],
    la: %i[female male],
  }.freeze

  def disciplines
    @disciplines ||= DISCIPLINES.map do |discipline, genders|
      klass = Discipline.group?(discipline) ? GroupScore : Score
      bests = genders.index_with { |gender| klass.best_of(discipline, gender, nil).order(:time).first&.decorate }
      { discipline:, bests: bests.compact }
    end
  end
end
