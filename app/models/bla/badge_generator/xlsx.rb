# frozen_string_literal: true

require 'caxlsx'

# Excel export of the badge generator: one row per person with the highest badge to award
Bla::BadgeGenerator::Xlsx = Struct.new(:generator, :base_url) do
  include Rails.application.routes.url_helpers

  def self.headline
    ['Person', 'Geschlecht', 'Vorhandenes Abzeichen', 'Neues Abzeichen',
     'HL-Zeit', 'HL-Wettkampf', 'HB-Zeit', 'HB-Wettkampf']
  end

  def filename
    "bla-vorschlaege-#{Date.current.year}.xlsx"
  end

  def to_stream
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: 'BLA-Vorschläge') { |sheet| build_sheet(sheet) }
    package.to_stream.read
  end

  def rows
    generator.people_with_badges.filter_map do |person, badges|
      badge = badges.compact.find(&:valid?)
      [person, badge] if badge
    end
  end

  protected

  def default_url_options
    { host: base_url }
  end

  def build_sheet(sheet)
    link_style = sheet.styles.add_style(fg_color: '0000FF', u: true)
    sheet.add_row(self.class.headline)
    rows.each { |person, badge| add_badge_row(sheet, person, badge, link_style) }
  end

  def add_badge_row(sheet, person, badge, link_style)
    hl = badge.hl_score
    hb = badge.hb_score
    row = sheet.add_row([
                          person.decorate.to_s,
                          person.decorate.gender_translated,
                          existing_badge(person),
                          badge.decorate.status,
                          hl&.decorate&.second_time,
                          competition_name(hl),
                          hb&.decorate&.second_time,
                          competition_name(hb),
                        ], types: :string)

    links = { 0 => person_url(person) }
    links[4] = links[5] = competition_url(hl.competition) if hl
    links[6] = links[7] = competition_url(hb.competition) if hb
    links.each do |column, url|
      sheet.add_hyperlink(location: url, ref: row.cells[column].r)
      row.cells[column].style = link_style
    end
  end

  def competition_name(score)
    score&.competition&.decorate.to_s
  end

  def existing_badge(person)
    badge = person.bla_badge&.decorate
    badge ? "#{badge.status} #{badge.year}" : nil
  end
end
