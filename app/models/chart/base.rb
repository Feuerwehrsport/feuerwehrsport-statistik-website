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
  end
end