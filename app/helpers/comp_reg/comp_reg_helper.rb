module CompReg::CompRegHelper
  def breadcrum
    items = [ link_to("Wettkampfanmeldungen", comp_reg_competitions_path) ]

    if resource_instance.present? && resource_instance.respond_to?(:competition)
      items.push(link_to(resource_instance.competition.name, comp_reg_competition_path(resource_instance.competition)))
    end
    begin
      items.push(link_to(resource_class.model_name.human(count: 0), action: :index))
    rescue ActionController::UrlGenerationError
    end
    if action_name == "index"
      items.push(t("scaffold.index"))
    else
      items.push(link_to("##{params[:id]}", action: :show)) if params[:id].present?
      items.push(t("scaffold.#{action_name}"))
    end
    render 'breadcrum', items: items
  end

  def team_pdf_overview(pdf, team)
    pdf.text "Mannschaftsanmeldung", align: :center, size: 18, style: :bold
    pdf.move_down 12
    pdf.text "- Teilnehmerliste A -", align: :center, size: 14
    pdf.move_down 12

    pdf.table([
      [
        { content: team.competition.name, size: 14, align: :center, font_style: :bold },
        { image: "#{Rails.root}/app/assets/images/disciplines/hb.png", image_height: 50, image_width: 50 },
        { image: "#{Rails.root}/app/assets/images/disciplines/fs.png", image_height: 50, image_width: 50 },
        { image: "#{Rails.root}/app/assets/images/disciplines/hl.png", image_height: 50, image_width: 50 },
        { image: "#{Rails.root}/app/assets/images/disciplines/la.png", image_height: 50, image_width: 50 },
      ],
      [
        { content: l(team.competition.date, format: :german), size: 14, align: :center },
        { content: "in #{team.competition.place}", size: 14, align: :center, colspan: 4 },
      ],
      [
        { content: "Name:", size: 12, align: :right },
        { content: team.with_number, size: 11, align: :left, colspan: 4, font_style: :italic },
      ],
      [
        { content: "Wertungsgruppe:", size: 12, align: :right },
        { content: ([g(team.gender)] + team.tag_names).join(", "), size: 11, align: :left, colspan: 4, font_style: :italic },
      ],
      [
        { content: "Mannschaftsleiter:", size: 12, align: :right },
        { content: team.team_leader, size: 11, align: :left, colspan: 4, font_style: :italic },
      ],
      [
        { content: "Straße, Nr.:", size: 12, align: :right },
        { content: team.street_with_house_number, size: 11, align: :left, colspan: 4, font_style: :italic },
      ],
      [
        { content: "PLZ, Ort:", size: 12, align: :right },
        { content: "#{team.postal_code} #{team.locality}", size: 11, align: :left, colspan: 4, font_style: :italic },
      ],
      [
        { content: "Telefon:", size: 12, align: :right },
        { content: team.phone_number, size: 11, align: :left, colspan: 4, font_style: :italic },
      ],
      [
        { content: "E-Mail-Adresse:", size: 12, align: :right },
        { content: team.email_address, size: 11, align: :left, colspan: 4, font_style: :italic },
      ],
      [
        { content: "Wertungen:", size: 12, align: :right },
        { content: team.team_assessment_participations.map(&:competition_assessment).join(", "), size: 11, align: :left, colspan: 4, font_style: :italic },
      ]
    ], cell_style: { borders: [] }, column_widths: [200, 60, 60, 60, 120])

    if team.competition.competition_assessments.for_people.present?
      pdf.start_new_page

      pdf.text "Namensliste", align: :center, size: 18, style: :bold
      pdf.move_down 12
      pdf.text "- Teilnehmerliste B -", align: :center, size: 14
      pdf.move_down 12


      pdf.table([
        [
          { content: team.competition.name, size: 14, align: :center, font_style: :bold },
          { image: "#{Rails.root}/app/assets/images/disciplines/hb.png", image_height: 50, image_width: 50 },
          { image: "#{Rails.root}/app/assets/images/disciplines/fs.png", image_height: 50, image_width: 50 },
          { image: "#{Rails.root}/app/assets/images/disciplines/hl.png", image_height: 50, image_width: 50 },
          { image: "#{Rails.root}/app/assets/images/disciplines/la.png", image_height: 50, image_width: 50 },
        ],
        [
          { content: l(team.competition.date, format: :german), size: 14, align: :center },
          { content: "in #{team.competition.place}", size: 14, align: :center, colspan: 4 },
        ],
        [
          { content: "Name:", size: 12, align: :right },
          { content: team.with_number, size: 11, align: :left, colspan: 4, font_style: :italic },
        ],
      ], cell_style: { borders: [] }, column_widths: [200, 60, 60, 60, 120])


      people = []

      line = []
      line.push("Nr.")
      line.push("Vorname")
      line.push("Nachname")
      line.push("Attribute")
      CompReg::CompetitionAssessment.requestable_for_person(team).decorate.each do |assessment|
        line.push(assessment.shortcut)
      end
      people.push(line)
      
      i = 0
      team.people.each do |person|
        line = []
        line.push(i += 1)
        line.push(person.first_name)
        line.push(person.last_name)
        line.push(person.tag_names.join(", "))
        CompReg::CompetitionAssessment.requestable_for_person(team).each do |assessment|
          line.push(person.person_assessment_participations.find_by(competition_assessment: assessment).try(:decorate).try(:short_type))
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

  def edit_participation(row, assessment)
    value = row.person_assessment_participations.find_by(competition_assessment: assessment).try(:decorate).try(:short_type)
    link = link_to(
      content_tag(:span, "", class: "glyphicon glyphicon-pencil"), 
      { action: :participations, controller: :people, id: row.id }, 
      { remote: true, class: "btn btn-default btn-xs pull-right" }
    )
    link = can?(:edit, row) ? link : ""
    "#{value.presence || "-"} #{link}".html_safe
  end
end