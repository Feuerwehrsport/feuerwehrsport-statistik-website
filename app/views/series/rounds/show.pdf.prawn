first = true
if @team_assessments_exists
  cups = @round.cups
  
  [:female, :male].each do |gender|
    if @round.team_assessment_rows(gender, true).present?
      pdf.start_new_page unless first
      first = false
      pdf_header(pdf, @round.to_s, "Mannschaft #{g(gender)}")

      lines = []
      headline = ['Platz', 'Team']
      cups.each do |cup|
        headline.push(cup.competition.place.to_s)
      end
      headline.push('Teil.', 'Bestzeit', 'Punkte')
      lines.push(headline)

      @round.team_assessment_rows(gender, true).map(&:decorate).each do |row|
        line = [row.rank, numbered_team_name(row, competition_id: @round.cups.map(&:competition_id), gender: gender)]
        cups.each do |cup|
          participations = row.participations_for_cup(cup)
          if participations.present?
            participation_lines = []
            participations.each do |participation|
              participation_lines.push([
                  discipline_name_short(participation.assessment.discipline),
                  participation.second_time_with_points
                ]
              )
            end
            line.push(pdf.make_table(participation_lines, cell_style: { size: 9, borders: [], padding: [1, 1, 2, 7]  }))
          else
            line.push('')
          end
        end
        line.push(row.count, row.second_best_time, row.points)
        lines.push(line)
      end

      pdf.table(lines,
        header: true,
        width: pdf.bounds.width,
        cell_style: { align: :center, size: 10 },
      ) do
        row(0).style(align: :center, font_style: :bold, size: 8)
        column(1).style(align: :left)
        cups.each_with_index do |cup, i|
          column(2 + i).style(size: 8)
        end
      end
    end
  end
end
pdf_footer(pdf, @round.to_s)
