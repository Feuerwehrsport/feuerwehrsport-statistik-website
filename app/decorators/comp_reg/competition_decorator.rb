module CompReg
  class CompetitionDecorator < ApplicationDecorator
    def to_s
      [name, german_date].join(" - ")
    end

    def german_date
      l(date, format: :german)
    end
  end
end