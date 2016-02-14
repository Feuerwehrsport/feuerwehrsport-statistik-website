module CompReg
  class CompetitionDecorator < ApplicationDecorator
    decorates_association :people
    decorates_association :admin_user

    def to_s
      [name, german_date].join(" - ")
    end

    def german_date
      l(date, format: :german)
    end
    
    def discipline_images(options={})
      object.discipline_array.map do |discipline|
        discipline_image(discipline, options)
      end.join(" ").html_safe
    end
  end
end