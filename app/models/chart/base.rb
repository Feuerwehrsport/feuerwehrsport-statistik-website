module Chart
  class Base
    include ActiveModel::Model
    include Draper::Decoratable
    include ApplicationHelper
    include LazyHighCharts::LayoutHelper
    include ActionView::Helpers::TranslationHelper

    GENDER_COLORS = {
      female: '#FEAE97',
      male: '#97E6FE',
    }.freeze

    protected

    def lazy_high_chart
      LazyHighCharts::HighChart.new
    end

    def render(hc)
      high_chart("high-chart-#{SecureRandom.hex(6)}", hc)
    end

    def gender_color(gender)
      GENDER_COLORS[normalize_gender(gender)]
    end

    def basic_gender_pie(data)
      hc = lazy_high_chart
      hc.legend(borderWidth: 0, margin: 0, padding: 5)
      hc.chart(type: 'pie', height: 150)
      hc.plotOptions(pie: { dataLabels: { enabled: false }, showInLegend: true })
      hc.series(name: 'Geschlecht', data: data)
      render(hc)
    end
  end
end
