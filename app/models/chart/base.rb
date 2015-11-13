module Chart
  class Base
    include ActiveModel::Model
    include Draper::Decoratable
    include ApplicationHelper
    include LazyHighCharts::LayoutHelper
    include ActionView::Helpers::TranslationHelper 

    def lazy_high_chart
      LazyHighCharts::HighChart.new
    end

    def render hc
      high_chart("high-chart-#{SecureRandom.hex(6)}", hc)
    end
  end
end