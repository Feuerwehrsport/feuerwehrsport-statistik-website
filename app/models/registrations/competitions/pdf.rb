# frozen_string_literal: true

Registrations::Competitions::Pdf = Struct.new(:competition, :ability) do
  include PrawnSupport
  include GenderNames

  def build
    prawn.text(competition.decorate.to_s, align: :center, size: 18, style: :bold)
    prawn.move_down 12
    prawn.text("#{competition.place} - Wettkampfanmeldung", align: :center, size: 14)
    prawn.move_down 12

    %i[female male].each { |gender| build_people_table(gender, people_by(gender)) }

    competition.teams.each do |team|
      prawn.start_new_page
      Registrations::Teams::Pdf.new(team).tap { |pdf| pdf.build_team_page(prawn) }
    end

    footer(competition.decorate.to_s)
  end

  protected

  def default_prawn_options
    super.merge(margin: [50, 40, 40, 40])
  end

  def build_people_table(gender, people)
    return if people.blank?

    prawn.move_down 12
    prawn.text "Einzelstarter #{g(gender)}", size: 14, style: :bold
    lines = [people_table_headline(gender)]

    people.each_with_index do |person, index|
      line = [index + 1, person.first_name, person.last_name, person.team_name, person.tag_names.join(', ')]
      competition.assessments.gender(gender).decorate.each do |assessment|
        unless Discipline.group?(assessment.discipline)
          line.push(person.person_assessment_participations.find_by(assessment:)&.decorate&.short_type)
        end
      end
      lines.push(line)
    end
    return if lines.count.zero?

    prawn.table(lines,
                header: true,
                width: prawn.bounds.width) do
      row(0).style(align: :center, font_style: :bold)
    end
  end

  def people_table_headline(gender)
    headline = ['Nr.', 'Vorname', 'Nachname', 'Mannschaft', 'Attribute']
    competition.assessments.gender(gender).decorate.each do |assessment|
      headline.push(assessment.shortcut) unless Discipline.group?(assessment.discipline)
    end
    headline
  end

  def teams_by(gender)
    competition.teams.gender(gender).decorate
  end

  def people_by(gender)
    competition.people.gender(gender).without_team.accessible_by(ability).decorate
  end
end
