module CompReg
  class PersonAssessmentParticipationDecorator < ApplicationDecorator
    def type
      t("assessment_types.#{assessment_type}_order", competitor_order: competitor_order)
    end

    def short_type
      t("assessment_types.#{assessment_type}_short_order", competitor_order: competitor_order)
    end

    def competitor_order
      if group_competitor?
        group_competitor_order
      elsif single_competitor?
        single_competitor_order
      else
        0
      end
    end
  end
end