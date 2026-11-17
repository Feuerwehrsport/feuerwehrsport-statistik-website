# frozen_string_literal: true

class Chart::CompetitionsScoreOverview < Chart::Base
  attr_accessor :competitions

  def year_overview
    month_counts = (1..12).map do |month|
      {
        name: t('date.month_names')[month],
        y: competitions.count { |c| c.object.date.month == month },
      }
    end
    column_chart(t('date.month_names_short'), month_counts)
  end

  def week_overview
    week_counts = (1..7).map do |wday|
      {
        name: t('date.day_names')[wday % 7],
        y: competitions.count { |c| c.object.date.wday == (wday % 7) },
      }
    end
    column_chart(t('date.day_names_short'), week_counts)
  end

  def disciplines_overview
    counts = disciplines_overview_counts

    data = []
    data.push(name: 'Alle', y: counts[0], color: PALETTE[2]) if counts[0] > 0
    data.push(name: 'Nur HL', y: counts[1], color: PALETTE[1]) if counts[1] > 0
    data.push(name: 'Nur HB', y: counts[2], color: PALETTE[0]) if counts[2] > 0
    data.push(name: 'Nur LA', y: counts[3], color: PALETTE[4]) if counts[3] > 0
    data.push(name: 'HB und HL', y: counts[4], color: PALETTE[3]) if counts[4] > 0
    data.push(name: 'Andere', y: counts[5], color: OTHER_COLOR) if counts[5] > 0

    pie_chart(data, name: 'Wettkämpfe')
  end

  def team_scores_overview
    counts = Hash.new 0
    competitions.each { |competition| counts[competition.score_type_id] += 1 if competition.score_type_id.present? }
    sorted = counts.sort_by { |_id, count| -count }
    data = sorted.map { |id, count| { name: ScoreType.find(id).decorate.to_s, y: count } }
    if data.size > PALETTE.size
      data = data.first(PALETTE.size - 1) + [{ name: 'Andere', y: data.drop(PALETTE.size - 1).sum { |d| d[:y] },
                                               color: OTHER_COLOR }]
    end
    pie_chart(data, name: 'Wettkämpfe')
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
    data.push(name: 'Keine', y: counts[0], color: OTHER_COLOR) if counts[0] > 0
    data.push(name: '1 bis 10', y: counts[1], color: SEQUENTIAL[1]) if counts[1] > 0
    data.push(name: '11 bis 20', y: counts[2], color: SEQUENTIAL[2]) if counts[2] > 0
    data.push(name: '21 bis 30', y: counts[3], color: SEQUENTIAL[3]) if counts[3] > 0
    data.push(name: '> 30', y: counts[4], color: SEQUENTIAL[4]) if counts[4] > 0

    pie_chart(data, name: 'Wettkämpfe')
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
    data.push(name: 'Keine', y: counts[0], color: OTHER_COLOR) if counts[0] > 0
    data.push(name: '1 bis 25', y: counts[1], color: SEQUENTIAL[1]) if counts[1] > 0
    data.push(name: '25 bis 50', y: counts[2], color: SEQUENTIAL[2]) if counts[2] > 0
    data.push(name: '50 bis 75', y: counts[3], color: SEQUENTIAL[3]) if counts[3] > 0
    data.push(name: '75 bis 100', y: counts[4], color: SEQUENTIAL[4]) if counts[4] > 0
    data.push(name: '> 100', y: counts[5], color: SEQUENTIAL[5]) if counts[5] > 0

    pie_chart(data, name: 'Wettkämpfe')
  end

  private

  def column_chart(labels, counts)
    bar_chart(labels:, values: counts.pluck(:y), name: 'Wettkämpfe', height: 140)
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
