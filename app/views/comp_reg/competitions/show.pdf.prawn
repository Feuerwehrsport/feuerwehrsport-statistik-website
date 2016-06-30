pdf.text resource_instance.to_s, align: :center, size: 18, style: :bold
pdf.move_down 12
pdf.text "#{resource_instance.place} - Wettkampfanmeldung", align: :center, size: 14
pdf.move_down 12

pdf.text "Beschreibung", size: 14, style: :bold
pdf.text strip_tags(simple_format(resource_instance.description.html_safe)), inline_format: true

[:female, :male].each do |gender|
  if @people[gender].present?
    pdf.move_down 12
    pdf.text "Einzelstarter #{g(gender)}", size: 14, style: :bold
    people = []

    line = []
    line.push("Nr.")
    line.push("Vorname")
    line.push("Nachname")
    line.push("Attribute")
    resource_instance.competition_assessments.gender(gender).decorate.each do |assessment|
      line.push(assessment.shortcut) unless Discipline.group?(assessment.discipline)
    end
    people.push(line)
    
    i = 0
    @people[gender].each do |person|
      line = []
      line.push(i += 1)
      line.push(person.first_name)
      line.push(person.last_name)
      line.push(person.tag_names.join(", "))
      resource_instance.competition_assessments.gender(gender).decorate.each do |assessment|
        unless Discipline.group?(assessment.discipline)
          line.push(person.person_assessment_participations.find_by(competition_assessment: assessment).try(:decorate).try(:short_type))
        end
      end
      people.push(line)
    end
    if people.count > 1
      pdf.table(people,
        header: true,
        width: pdf.bounds.width) do
        row(0).style(align: :center, font_style: :bold)
      end
    end
  end
end


resource_instance.teams.each do |team|
  pdf.start_new_page
  team.decorate.team_pdf_overview(pdf)
end

pdf_footer(pdf, resource_instance.to_s)