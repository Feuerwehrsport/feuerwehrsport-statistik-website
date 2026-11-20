# frozen_string_literal: true

# Excel export of a competition: overview sheet and one sheet per discipline
Competition::Xlsx = Struct.new(:competition, :calc) do
  include XlsxSupport
  include GenderNames
  include DisciplineNamesAndImages
  include NumberedTeamNames

  def filename
    "#{competition.decorate.to_s.parameterize}.xlsx"
  end

  def build(workbook)
    workbook.add_worksheet(name: 'Übersicht') { |sheet| build_overview(sheet) }

    calc.disciplines.each do |discipline|
      if Discipline.group?(discipline.discipline)
        build_group_discipline(workbook, discipline)
      elsif discipline.discipline == :zk
        build_double_event_discipline(workbook, discipline)
      else
        build_single_discipline(workbook, discipline)
        build_group_assessment(workbook, discipline) if !discipline.category && competition.score_type.present?
      end
    end
  end

  private

  def build_overview(sheet)
    decorated = competition.decorate
    sheet.add_row(['Wettkampf', decorated.to_s])
    sheet.add_row(['Name', decorated.name])
    sheet.add_row(['Typ', decorated.event.to_s])
    sheet.add_row(['Ort', decorated.place.to_s])
    if calc.single_score_count.positive?
      sheet.add_row(['Mannschaftswertung', decorated.score_type.present? ? decorated.score_type.to_s : 'Keine'])
    end
    sheet.add_row(['Datum', decorated.date])
    sheet.add_row([])
    sheet.add_row([])

    sheet.add_row(['', 'Frauen', 'Männer'])
    calc.single_categories.each do |discipline, finals|
      finals.each do |final|
        name = discipline_name_short(discipline)
        name += " #{final_name(final)}" if final
        sheet.add_row([name, *gender_counts(discipline, final)])
      end
    end
    calc.group_categories.each do |discipline, types|
      types.each { |type| sheet.add_row([discipline_name_short(discipline), *gender_counts(discipline, type)]) }
    end
  end

  def build_group_discipline(workbook, discipline)
    name = "#{discipline_name_short(discipline.discipline)} #{g_symbol(discipline.gender)} " \
           "(#{discipline.category.id})"
    scores = discipline.scores.sort do |a, b|
      a.sort_method(b, method: :competition_scores_from_team_with_run)
    end
    lines = scores.map do |score|
      [numbered_team_name(score), *score.competition_scores_from_team_with_run.map { |s| s.decorate.second_time }]
    end
    add_times_sheet(workbook, name, ['Mannschaft'], lines)
  end

  def build_double_event_discipline(workbook, discipline)
    name = "#{discipline_name_short(discipline.discipline)} #{g_symbol(discipline.gender)}"
    workbook.add_worksheet(name:) do |sheet|
      sheet.add_row(%w[Nachname Vorname HB HL Zeit])
      discipline.scores.sort.each do |score|
        sheet.add_row(
          [score.person.last_name, score.person.first_name, score.second_hb, score.second_hl, score.second_time],
        )
      end
    end
  end

  def build_single_discipline(workbook, discipline)
    name = "#{discipline_name_short(discipline.discipline.key)} #{g_symbol(discipline.gender)} " \
           "#{final_name(discipline.category)} #{discipline.discipline.id}"
    lines = discipline.scores.sort.map do |score|
      [score.person.last_name, score.person.first_name, *score.similar_scores.map { |s| s.decorate.second_time }]
    end
    add_times_sheet(workbook, name, %w[Nachname Vorname], lines)
  end

  def build_group_assessment(workbook, discipline)
    name = "#{discipline_name_short(discipline.discipline.key)} #{g_symbol(discipline.gender)} " \
           "Mannschaft #{discipline.discipline.id}"
    workbook.add_worksheet(name:) do |sheet|
      sheet.add_row(%w[Team Summe Wertung Außerhalb])
      competition.decorate.group_assessment(discipline.discipline, discipline.gender).each do |ga|
        sheet.add_row([
                        numbered_team_name(ga),
                        ga.second_time,
                        ga.score_in_assessment.map { |s| s.person.short_name }.join(', '),
                        ga.score_out_assessment.map { |s| s.person.short_name }.join(', '),
                      ])
      end
    end
  end

  def add_times_sheet(workbook, name, headline, lines)
    times = lines.map { |line| line.size - headline.size }.max || 0
    workbook.add_worksheet(name:) do |sheet|
      sheet.add_row(headline + Array.new(times) { |i| "Zeit #{i + 1}" })
      lines.each { |line| sheet.add_row(line) }
    end
  end

  def gender_counts(discipline, category)
    %i[female male].map do |gender|
      count = calc.discipline(discipline, gender, category).try(:count)
      count.to_i.positive? ? count : ''
    end
  end

  def final_name(final_count)
    ApplicationHelper::FINAL_NAMES[final_count]
  end
end
