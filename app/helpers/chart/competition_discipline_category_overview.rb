# frozen_string_literal: true

class Chart::CompetitionDisciplineCategoryOverview < Chart::Base
  include DisciplineNamesAndImages
  include NumberedTeamNames

  attr_accessor :discipline

  def discipline_scores
    discipline.scores.reject(&:time_invalid?).sort_by(&:time)
  end

  def group_scores_overview
    scores = discipline_scores
    scores_overview(scores.map { |s| numbered_team_name(s) }, scores.map { |s| s.time.to_f / 100 })
  end

  def single_scores_overview
    scores = discipline_scores
    scores_overview(scores.map { |s| s.person.to_s }, scores.map { |s| s.time.to_f / 100 })
  end

  def double_event_scores_overview
    scores = discipline_scores
    scores_overview(scores.map { |s| s.person.short_name }, scores.map { |s| s.time.to_f / 100 },
                    hb: scores.map { |s| s.hb.to_f / 100 }, hl: scores.map { |s| s.hl.to_f / 100 })
  end

  def scores_overview(names, times, hb: nil, hl: nil)
    datasets = [{ label: discipline_name(discipline.discipline), data: times,
                  color: discipline_color(discipline_key) }]
    if hb.present?
      datasets.push({ label: discipline_name(:hb), data: hb, color: discipline_color(:hb), dashed: true },
                    { label: discipline_name(:hl), data: hl, color: discipline_color(:hl), dashed: true })
    end
    line_chart(labels: names.each_index.map { |i| "#{i + 1}." }, names:, datasets:, height: 160,
               legend: hb.present?)
  end

  def discipline_key
    discipline.discipline.respond_to?(:key) ? discipline.discipline.key : discipline.discipline
  end

  def invalid_pie
    valid = discipline.all_scores.valid.count
    valid_pie_chart(discipline_name(discipline.discipline), valid:, invalid: discipline.all_scores.count - valid)
  end
end
