# frozen_string_literal: true

class Chart::CompetitionsScoreOverview < Chart::Base
  attr_accessor :competitions

  def year_overview
    month_counts = (1..12).map do |month|
      {
        name: t('date.month_names')[month - 1],
        y: competitions.count { |c| c.object.date.month == month },
      }
    end
    column_chart_style do |hc|
      hc.xAxis(categories: t('date.month_names_short'))
      hc.series(name: 'Wettkämpfe', data: month_counts)
    end
  end

  def week_overview
    week_counts = (1..7).map do |wday|
      {
        name: t('date.day_names')[wday],
        y: competitions.count { |c| c.object.date.wday == (wday % 7) },
      }
    end
    column_chart_style do |hc|
      hc.xAxis(categories: t('date.day_names_short'))
      hc.series(name: 'Wettkämpfe', data: week_counts)
    end
  end

  def disciplines_overview
    counts = disciplines_overview_counts

    data = []
    data.push(name: 'Alle', y: counts[0]) if counts[0] > 0
    data.push(name: 'Nur HL', y: counts[1]) if counts[1] > 0
    data.push(name: 'Nur HB', y: counts[2]) if counts[2] > 0
    data.push(name: 'Nur LA', y: counts[3]) if counts[3] > 0
    data.push(name: 'HB und HL', y: counts[4]) if counts[4] > 0
    data.push(name: 'Andere', y: counts[5]) if counts[5] > 0

    lazy_high_chart do |hc|
      hc.chart(type: 'pie', height: 120)
      hc.plotOptions(pie: { dataLabels: { format: '{point.percentage:.1f}%', distance: 0 }, showInLegend: true })
      hc.legend(align: :right, verticalAlign: :middle, layout: :vertical)
      hc.series(name: 'Wettkämpfe', data:, colorByPoint: true)
    end
  end

  def team_scores_overview
    counts = Hash.new 0
    competitions.each { |competition| counts[competition.score_type_id] += 1 if competition.score_type_id.present? }
    data = counts.map { |id, count| { name: ScoreType.find(id).decorate.to_s, y: count } }
    lazy_high_chart do |hc|
      hc.chart(type: 'pie', height: 120)
      hc.plotOptions(pie: { dataLabels: { format: '{point.percentage:.1f}%', distance: 0 }, showInLegend: true })
      hc.legend(align: :right, verticalAlign: :middle, layout: :vertical)
      hc.series(name: 'Wettkämpfe', data:, colorByPoint: true)
    end
  end

  def teams_count_overview
    counts = Hash.new 0
    competitions.each do |competition|
      if competition.teams_count == 0
        counts[0] += 1
      elsif competition.teams_count < 11
        counts[1] += 1
      elsif competition.teams_count < 21
        counts[2] += 1
      elsif competition.teams_count < 31
        counts[3] += 1
      else
        counts[4] += 1
      end
    end

    data = []
    data.push(name: 'Keine', y: counts[0]) if counts[0] > 0
    data.push(name: '1 bis 10', y: counts[1]) if counts[1] > 0
    data.push(name: '11 bis 20', y: counts[2]) if counts[2] > 0
    data.push(name: '21 bis 30', y: counts[3]) if counts[3] > 0
    data.push(name: '> 30', y: counts[4]) if counts[4] > 0

    lazy_high_chart do |hc|
      hc.chart(type: 'pie', height: 120)
      hc.plotOptions(pie: { dataLabels: { format: '{point.percentage:.1f}%', distance: 0 }, showInLegend: true })
      hc.legend(align: :right, verticalAlign: :middle, layout: :vertical)
      hc.series(name: 'Wettkämpfe', data:, colorByPoint: true)
    end
  end

  def people_count_overview
    counts = Hash.new 0
    competitions.each do |competition|
      if competition.people_count == 0
        counts[0] += 1
      elsif competition.people_count < 26
        counts[1] += 1
      elsif competition.people_count < 51
        counts[2] += 1
      elsif competition.people_count < 76
        counts[3] += 1
      elsif competition.people_count < 101
        counts[4] += 1
      else
        counts[5] += 1
      end
    end

    data = []
    data.push(name: 'Keine', y: counts[0]) if counts[0] > 0
    data.push(name: '1 bis 25', y: counts[1]) if counts[1] > 0
    data.push(name: '25 bis 50', y: counts[2]) if counts[2] > 0
    data.push(name: '50 bis 75', y: counts[3]) if counts[3] > 0
    data.push(name: '75 bis 100', y: counts[4]) if counts[4] > 0
    data.push(name: '> 100', y: counts[5]) if counts[5] > 0

    lazy_high_chart do |hc|
      hc.chart(type: 'pie', height: 120)
      hc.plotOptions(pie: { dataLabels: { format: '{point.percentage:.1f}%', distance: 0 }, showInLegend: true })
      hc.legend(align: :right, verticalAlign: :middle, layout: :vertical)
      hc.series(name: 'Wettkämpfe', data:, colorByPoint: true)
    end
  end

  private

  def column_chart_style
    lazy_high_chart do |hc|
      hc.legend(enabled: false)
      hc.chart(type: 'column', height: 120)
      hc.plotOptions(series: { pointWidth: 6 })
      hc.yAxis(endOnTick: false, title: nil)
      yield(hc)
    end
  end

  def discipline_count(competition, *disciplines)
    disciplines.sum { |discipline| competition.object.send(discipline) }
  end

  def disciplines_overview_counts
    counts = Hash.new 0
    competitions.each do |competition|
      if discipline_count(competition, :hb_male, :hb_female) > 0 &&
         discipline_count(competition, :hl_male, :hl_female) > 0 &&
         discipline_count(competition, :fs_male, :fs_female) > 0 &&
         discipline_count(competition, :gs) > 0
        counts[0] += 1
      elsif discipline_count(competition, :hl_male, :hl_female) > 0 &&
            discipline_count(competition, :hb_male, :hb_female, :fs_male, :fs_female, :la_male, :la_female, :gs) == 0
        counts[1] += 1
      elsif discipline_count(competition, :hb_male, :hb_female) > 0 &&
            discipline_count(competition, :hl_male, :hl_female, :fs_male, :fs_female, :la_male, :la_female, :gs) == 0
        counts[2] += 1
      elsif discipline_count(competition, :la_male, :la_female) > 0 &&
            discipline_count(competition, :hl_male, :hl_female, :fs_male, :fs_female, :hb_male, :hb_female, :gs) == 0
        counts[3] += 1
      elsif discipline_count(competition, :hb_male, :hb_female) > 0 &&
            discipline_count(competition, :hl_male, :hl_female) > 0 &&
            discipline_count(competition, :fs_male, :fs_female, :la_male, :la_female, :gs) == 0
        counts[4] += 1
      else
        counts[5] += 1
      end
    end
    counts
  end
end
