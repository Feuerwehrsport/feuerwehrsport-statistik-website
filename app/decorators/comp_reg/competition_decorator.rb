module CompReg
  class CompetitionDecorator < ApplicationDecorator
    decorates_association :people

    def to_s
      [name, german_date].join(" - ")
    end

    def german_date
      l(date, format: :german)
    end
  end
end