# frozen_string_literal: true
Series::Assessments::Pdf = Struct.new(:assessment) do
  include PrawnSupport
  decorates_assigned :assessment
  delegate :round, :cups, to: :assessment

  def build
    header(assessment.to_s, round.to_s, discipline: assessment.discipline)
    lines = []
    headline = %w[Platz Name]
    cups.each do |cup|
      headline.push(cup.competition.place.to_s)
    end
    headline.push('Bestzeit', 'Summe', 'Teil.', 'Punkte')

    lines.push(headline)
    assessment.rows.each do |row|
      line = [row.rank, "#{row.entity.last_name}, #{row.entity.first_name}"]
      cups.each do |cup|
        line.push(series_assessment_cup_participation(cup, row))
      end
      line.push(row.second_best_time, row.second_sum_time, row.count, row.points)
      lines.push(line)
    end

    prawn.table(lines, header: true, width: prawn.bounds.width, cell_style: { align: :center, size: 10 }) do |t|
      t.row(0).style(align: :center, font_style: :bold, size: 8)
      t.column(1).style(align: :left)
      cups.each_with_index do |_cup, i|
        t.column(2 + i).style(size: 8)
      end
    end

    footer(assessment.to_s, assessment.round.to_s)
  end

  protected

  def series_assessment_cup_participation(cup, row)
    row.participation_for_cup(cup).try(:second_time_with_points) || ''
  end

  def default_prawn_options
    super.merge(margin: [50, 40, 40, 40], page_layout: :landscape)
  end
end
