module Chart
  class Base
    include ActiveModel::Model
    include Draper::Decoratable
    include ApplicationHelper
    include LazyHighCharts::LayoutHelper
    include ActionView::Helpers::TranslationHelper 

    GENDER_COLORS = {
      female: "#E20800",
      male: "#37A42C",
    }

    def lazy_high_chart
      LazyHighCharts::HighChart.new
    end

    def render hc
      high_chart("high-chart-#{SecureRandom.hex(6)}", hc)
    end

    def gender_color(gender)
      GENDER_COLORS[normalize_gender(gender)]
    end
  end
end