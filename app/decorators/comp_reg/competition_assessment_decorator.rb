module CompReg
  class CompetitionAssessmentDecorator < ApplicationDecorator
    def to_s
      [name, discipline_name(discipline)].reject(&:blank?).join(" - ")
    end

    def with_gender
      "#{to_s} #{g(gender)}"
    end
  end
end