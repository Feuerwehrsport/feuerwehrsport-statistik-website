module Series
  class AssessmentDecorator < ApplicationDecorator
    decorates_association :cups
    decorates_association :participations
    decorates_association :round

    def to_s
      [discipline_name(discipline), name, translated_gender].select(&:present?).join(" - ")
    end
    
    def rows
      object.rows.map(&:decorate)
    end

    def calculation_description
      ActionController::Base.new.render_to_string(
        partial: "series/participation_rows/#{aggregate_type.underscore}"
      )
    end
  end
end
