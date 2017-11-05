pdf_header(pdf, resource.to_s, resource.round.to_s, discipline: resource.discipline)

cups = resource.cups
lines = []
headline = ['Platz', 'Name']
cups.each do |cup|
  headline.push(cup.competition.place.to_s)
end
headline.push('Bestzeit', 'Summe', 'Teil.', 'Punkte')

lines.push(headline)
resource.rows.each do |row|
  line = [row.rank, "#{row.entity.last_name}, #{row.entity.first_name}"]
  cups.each do |cup|
    line.push(series_assessment_cup_participation(cup, row, html: false))
  end
  line.push(row.second_best_time, row.second_sum_time, row.count, row.points)
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

pdf_footer(pdf, resource.to_s, resource.round.to_s)
