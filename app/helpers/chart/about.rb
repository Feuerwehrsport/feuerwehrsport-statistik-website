# frozen_string_literal: true

class Chart::About < Chart::Base
  MODELS = [Competition, Score, GroupScore, Team, Person, Place, PersonParticipation, Link].freeze
  START_DATE = Date.new(2016, 5, 1)

  # one small chart per table, the counts are too different for a shared axis
  def competition_creations
    tag.div(class: 'chart-grid') do
      safe_join(MODELS.map do |klass|
        name = klass.model_name.human(count: :many)
        points = data(klass)
        tag.div(class: 'chart-grid-item') do
          tag.h3(name) + render_chart(type: 'line', height: 140, format: 'date', data: {
                                        datasets: [{ label: name, data: points, borderColor: PALETTE.first,
                                                     backgroundColor: PALETTE.first, stepped: 'before',
                                                     pointRadius: 0 }],
                                      }, options: { plugins: { legend: { display: false } } })
        end
      end)
    end
  end

  def data(klass)
    dates = {}
    absolute = 0
    klass.reorder(:created_at).pluck('created_at::DATE as date').each do |date|
      dates[[date, START_DATE].max] = absolute += 1
    end
    dates[Date.current] = absolute
    dates.map { |date, count| { x: date.to_time.to_i * 1000, y: count } }
  end
end
