# frozen_string_literal: true

Series::Rounds::Pdf = Struct.new(:round) do
  include PrawnSupport
  include NumberedTeamNames
  include DisciplineNamesAndImages

  decorates_assigned :round
  delegate :cups, to: :round

  def build
    first_page = true

    round.team_assessments_configs.each do |config|
      next if config.rows.blank?

      prawn.start_new_page unless first_page
      first_page = false

      build_assessment_table(config)
    end
    footer(round.to_s)
  end

  protected

  def default_prawn_options
    super.merge(margin: [50, 40, 40, 40], page_layout: :landscape)
  end

  def build_assessment_table(config)
    header(round.to_s, "Mannschaft #{config.name}")

    headline = %w[Platz Team]
    cups.each do |cup|
      headline.push(cup.competition.place.to_s)
    end
    config.show_columns_config.each do |col|
      headline.push(col[:name])
    end
    lines = [headline]

    config.rows.map(&:decorate).each do |row|
      line = [row.rank,
              numbered_team_name(row, competition_id: round.cups.map(&:competition_id), gender: row.team_gender)]
      cups.each do |cup|
        participations = row.participations_for_cup(cup)
        if participations.present?
          participation_lines = participations.map do |participation|
            [discipline_name_short(participation.team_assessment.discipline),
             participation.second_time_with_points(html: false)]
          end
          line.push(prawn.make_table(participation_lines, cell_style: { size: 9, borders: [], padding: [1, 1, 2, 7] }))
        else
          line.push('')
        end
      end

      config.show_columns_config.each do |col|
        line.push(row.public_send(col[:method]))
      end
      lines.push(line)
    end

    prawn.table(lines, header: true, width: prawn.bounds.width, cell_style: { align: :center, size: 10 }) do |t|
      t.row(0).style(align: :center, font_style: :bold, size: 8)
      t.column(1).style(align: :left)
      cups.each_with_index do |_cup, i|
        t.column(2 + i).style(size: 8)
      end
    end
  end
end
