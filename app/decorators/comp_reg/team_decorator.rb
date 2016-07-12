module CompReg
  class TeamDecorator < ApplicationDecorator
    decorates_association :competition
    decorates_association :team_assessment_participations
    decorates_association :admin_user
    decorates_association :federal_state

    def to_s
      name
    end

    def with_number
      "#{name} #{team_number}"
    end

    def team_pdf_overview(pdf, footer: false)
      pdf.text 'Mannschaftsanmeldung', align: :center, size: 18, style: :bold
      pdf.move_down 12
      pdf.text '- Teilnehmerliste A -', align: :center, size: 14
      pdf.move_down 12

      location_line = "#{postal_code} #{locality}"
      location_line += " / #{federal_state}" if federal_state.present?

      pdf.table([
        [
          { content: competition.name, size: 14, align: :center, font_style: :bold },
          { image: "#{Rails.root}/app/assets/images/disciplines/hb.png", image_height: 50, image_width: 50 },
          { image: "#{Rails.root}/app/assets/images/disciplines/fs.png", image_height: 50, image_width: 50 },
          { image: "#{Rails.root}/app/assets/images/disciplines/hl.png", image_height: 50, image_width: 50 },
          { image: "#{Rails.root}/app/assets/images/disciplines/la.png", image_height: 50, image_width: 50 },
        ],
        [
          { content: h.l(competition.date, format: :german), size: 14, align: :center },
          { content: "in #{competition.place}", size: 14, align: :center, colspan: 4 },
        ],
        [
          { content: 'Name:', size: 12, align: :right },
          { content: with_number, size: 11, align: :left, colspan: 4, font_style: :italic },
        ],
        [
          { content: 'Wertungsgruppe:', size: 12, align: :right },
          { content: ([translated_gender] + tag_names).join(", "), size: 11, align: :left, colspan: 4, font_style: :italic },
        ],
        [
          { content: 'Mannschaftsleiter:', size: 12, align: :right },
          { content: team_leader, size: 11, align: :left, colspan: 4, font_style: :italic },
        ],
        [
          { content: "Straße, Nr.:", size: 12, align: :right },
          { content: street_with_house_number, size: 11, align: :left, colspan: 4, font_style: :italic },
        ],
        [
          { content: "PLZ, Ort:", size: 12, align: :right },
          { content: location_line, size: 11, align: :left, colspan: 4, font_style: :italic },
        ],
        [
          { content: "Telefon:", size: 12, align: :right },
          { content: phone_number, size: 11, align: :left, colspan: 4, font_style: :italic },
        ],
        [
          { content: "E-Mail-Adresse:", size: 12, align: :right },
          { content: email_address, size: 11, align: :left, colspan: 4, font_style: :italic },
        ],
        [
          { content: "Wertungen:", size: 12, align: :right },
          { content: team_assessment_participations.map(&:competition_assessment).join(", "), size: 11, align: :left, colspan: 4, font_style: :italic },
        ]
      ], cell_style: { borders: [] }, column_widths: [200, 60, 60, 60, 120])

      if competition.competition_assessments.for_people.present?
        pdf.start_new_page

        pdf.text "Namensliste", align: :center, size: 18, style: :bold
        pdf.move_down 12
        pdf.text "- Teilnehmerliste B -", align: :center, size: 14
        pdf.move_down 12


        pdf.table([
          [
            { content: competition.name, size: 14, align: :center, font_style: :bold },
            { image: "#{Rails.root}/app/assets/images/disciplines/hb.png", image_height: 50, image_width: 50 },
            { image: "#{Rails.root}/app/assets/images/disciplines/fs.png", image_height: 50, image_width: 50 },
            { image: "#{Rails.root}/app/assets/images/disciplines/hl.png", image_height: 50, image_width: 50 },
            { image: "#{Rails.root}/app/assets/images/disciplines/la.png", image_height: 50, image_width: 50 },
          ],
          [
            { content: h.l(competition.date, format: :german), size: 14, align: :center },
            { content: "in #{competition.place}", size: 14, align: :center, colspan: 4 },
          ],
          [
            { content: "Name:", size: 12, align: :right },
            { content: with_number, size: 11, align: :left, colspan: 4, font_style: :italic },
          ],
        ], cell_style: { borders: [] }, column_widths: [200, 60, 60, 60, 120])


        people_list = []

        line = []
        line.push("Nr.")
        line.push("Vorname")
        line.push("Nachname")
        line.push("Attribute")
        CompReg::CompetitionAssessment.requestable_for_person(object).decorate.each do |assessment|
          line.push(assessment.shortcut)
        end
        people_list.push(line)
        
        i = 0
        people.each do |person|
          line = []
          line.push(i += 1)
          line.push(person.first_name)
          line.push(person.last_name)
          line.push(person.tag_names.join(", "))
          CompReg::CompetitionAssessment.requestable_for_person(object).each do |assessment|
            line.push(person.person_assessment_participations.find_by(competition_assessment: assessment).try(:decorate).try(:short_type))
          end
          people_list.push(line)
        end
        if people_list.count > 1
          pdf.table(people_list,
            header: true,
            width: pdf.bounds.width) do
            row(0).style(align: :center, font_style: :bold)
          end
        end
      end
      h.pdf_footer(pdf, competition.to_s) if footer
    end
  end
end