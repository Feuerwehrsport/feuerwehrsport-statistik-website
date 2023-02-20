# frozen_string_literal: true

class Chart::TeamOverview < Chart::Base
  def federal_states_pie
    data = Team.where(state: State::FEDERAL).group(:state).count
    states_pie(data)
  end

  def international_states_pie
    data = Team.where(state: State::INTERNATIONAL).where.not(state: 'DE').group(:state).count
    states_pie(data)
  end

  def activities_for_years
    data = Year.where(Year.arel_table[:year].gt(1995)).pluck(:year).map do |year|
      {
        name: year.to_i.to_s,
        y: TeamCompetition.joins(:competition)
                          .where("EXTRACT(YEAR FROM competitions.date) = '#{year.to_i}'")
                          .group(:team_id).count.count,
      }
    end
    hc = lazy_high_chart
    hc.legend(enabled: false)
    hc.chart(type: 'column', height: 120)
    hc.plotOptions(series: { pointWidth: 6 })
    hc.yAxis(endOnTick: false, title: nil)
    hc.xAxis(categories: data.pluck(:name))
    hc.series(name: 'Mannschaften', data: data)
    render(hc)
  end

  protected

  def states_pie(data)
    data = data.map { |k, v| { short_name: k, name: State::ALL[k], y: v } }
    data = data.reject { |a| a[:y].blank? }.sort_by { |a| a[:y] }.reverse
    hc = lazy_high_chart
    hc.legend(enabled: false)
    hc.chart(type: 'column', height: 120)
    hc.plotOptions(series: { pointWidth: 6 })
    hc.yAxis(endOnTick: false, title: nil)
    hc.xAxis(categories: data.pluck(:short_name))
    hc.series(name: 'Mannschaften', data: data)
    render(hc)
  end
end
