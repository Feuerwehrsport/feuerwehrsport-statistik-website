module CompReg
  class CompetitionAssessmentDecorator < ApplicationDecorator
    def to_s
      [name, discipline_name(discipline)].reject(&:blank?).join(" - ")
    end
  end
end