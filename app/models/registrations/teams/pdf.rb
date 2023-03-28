# frozen_string_literal: true

Registrations::Teams::Pdf = Struct.new(:team) do
  include PrawnSupport
  include GenderNames
  delegate :competition, to: :team

  def build
    build_team_page
    footer(competition.decorate.to_s)
  end

  def build_team_page(external_prawn = nil)
    @prawn = external_prawn if external_prawn

    prawn.text 'Mannschaftsanmeldung', align: :center, size: 18, style: :bold
    prawn.move_down 12
    prawn.text '- Teilnehmerliste A -', align: :center, size: 14
    prawn.move_down 12

    overview_table
    people_table if competition.assessments.for_people.present? && team.people.present?
  end

  protected

  def header_table_head
    [
      [
        { content: competition.name, size: 14, align: :center, font_style: :bold },
        { image: dicipline_image_path(:hb), image_height: 50, image_width: 50 },
        { image: dicipline_image_path(:fs), image_height: 50, image_width: 50 },
        { image: dicipline_image_path(:hl), image_height: 50, image_width: 50 },
        { image: dicipline_image_path(:la), image_height: 50, image_width: 50 },
      ], [
        { content: competition.decorate.date, size: 14, align: :center },
        { content: "in #{competition.place}", size: 14, align: :center, colspan: 4 },
      ]
    ]
  end

  def overview_table
    lines = header_table_head
    {
      'Name:' => team.decorate.with_number,
      'Wertungsgruppe:' => team.decorate.band_with_tags,
      'Mannschaftsleiter:' => team.team_leader,
      'Telefon:' => team.phone_number,
      'E-Mail-Adresse:' => team.email_address,
      'Wertungen:' => team.team_assessment_participations.decorate.map(&:assessment).join(', '),
      'Wettkämpfer:' => people_line,
    }.each do |name, value|
      lines.push([
                   { content: name, size: 12, align: :right },
                   { content: value, size: 11, align: :left, colspan: 4, font_style: :italic },
                 ])
    end
    prawn.table(lines, cell_style: { borders: [] }, column_widths: [200, 60, 60, 60, 120])
  end

  def location_line
    line = "#{team.postal_code} #{team.locality}"
    line += " / #{team.decorate.federal_state}" if team.federal_state.present?
    line
  end

  def people_line
    return 'Keine Einzelwertungen' if competition.assessments.for_people.blank?

    team.people.present? ? team.people.count.to_s : 'Keine Wettkämpfer'
  end

  def people_table
    prawn.start_new_page

    prawn.text 'Namensliste', align: :center, size: 18, style: :bold
    prawn.move_down 12
    prawn.text '- Teilnehmerliste B -', align: :center, size: 14
    prawn.move_down 12

    lines = header_table_head
    lines.push([
                 { content: 'Name:', size: 12, align: :right },
                 { content: team.decorate.with_number, size: 11, align: :left, colspan: 4, font_style: :italic },
               ])
    prawn.table(lines, cell_style: { borders: [] }, column_widths: [200, 60, 60, 60, 120])

    people_list = []
    line = ['Nr.', 'Vorname', 'Nachname', 'Attribute']
    Registrations::Assessment.requestable_for(team.people.first).decorate.each do |assessment|
      line.push(assessment.shortcut)
    end
    people_list.push(line)

    team.people.each_with_index do |person, index|
      line = [index + 1, person.first_name, person.last_name, person.tag_names.join(', ')]
      Registrations::Assessment.requestable_for(team.people.first).each do |assessment|
        line.push(person.person_assessment_participations.find_by(assessment:)&.decorate&.short_type)
      end
      people_list.push(line)
    end
    prawn.table(people_list, header: true, width: prawn.bounds.width) do
      row(0).style(align: :center, font_style: :bold)
    end
  end

  def dicipline_image_path(discipline)
    Rails.root.join("app/assets/images/disciplines/#{discipline}.png")
  end
end
