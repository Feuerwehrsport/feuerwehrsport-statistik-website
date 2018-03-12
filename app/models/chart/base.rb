module Chart
  class Base
    include ActiveModel::Model
    include Draper::Decoratable
    include ApplicationHelper
    include LazyHighCharts::LayoutHelper
    include ActionView::Helpers::TranslationHelper
    attr_accessor :context

    delegate :request, to: :context

    GENDER_COLORS = {
      female: '#FEAE97',
      male: '#97E6FE',
    }.freeze

    protected

    def lazy_high_chart
      LazyHighCharts::HighChart.new
    end

    def render(hc)
      @div_id = "high-chart-#{SecureRandom.hex(6)}"
      high_chart(@div_id, hc)
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

    private

    def encapsulate_js(core_js)
      js_output = if request_is_xhr?
                    "#{js_start} #{core_js} #{js_end}"
                  # Turbolinks.version < 5
                  else
                    <<-EOJS
        #{js_start}
          M3.ready(function(){
            if ($('##{@div_id}').length === 0) return;
            #{core_js}
          });
        #{js_end}
        EOJS
                  end

      if defined?(raw)
        return raw(js_output)
      else
        return js_output
      end
    end
  end
end
