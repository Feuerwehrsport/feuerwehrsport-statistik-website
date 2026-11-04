# frozen_string_literal: true

class Chart::Base
  include ActiveModel::Model
  include ActionView::Helpers::TagHelper

  delegate :t, to: I18n
  attr_accessor :request

  protected

  def lazy_high_chart(&)
    hchart = Chart::HighChart.new.tap(&)
    @div_id = "high-chart-#{SecureRandom.hex(6)}"
    high_chart(@div_id, hchart)
  end

  def high_chart(placeholder, hchart)
    hchart.options[:chart][:renderTo] = placeholder
    core_js = <<~JS
      var options = #{hchart.to_h.to_json};
      window.chart_#{placeholder.underscore} = new Highcharts.Chart(options);
    JS
    encapsulate_js(core_js).concat(content_tag(:div, '', id: placeholder))
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

    raw(js_output)
  end

  def request_is_xhr?
    request.respond_to?(:xhr?) && request.xhr?
  end

  def js_start
    "<script type=\"text/javascript\">\n(function() {\n"
  end

  def js_end
    "})()\n</script>\n"
  end
end
