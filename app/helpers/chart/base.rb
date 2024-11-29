# frozen_string_literal: true

class Chart::Base
  include ActiveModel::Model
  include LazyHighCharts::LayoutHelper
  delegate :t, to: I18n
  attr_accessor :request

  protected

  def lazy_high_chart(&)
    hchart = LazyHighCharts::HighChart.new.tap(&)
    @div_id = "high-chart-#{SecureRandom.hex(6)}"
    high_chart(@div_id, hchart)
  end

  def basic_gender_pie(data)
    lazy_high_chart do |hc|
      hc.legend(borderWidth: 0, margin: 0, padding: 5)
      hc.chart(type: 'pie', height: 150)
      hc.plotOptions(pie: { dataLabels: { enabled: false }, showInLegend: true })
      hc.series(name: 'Geschlecht', data:)
    end
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
      raw(js_output)
    else
      js_output
    end
  end
end
