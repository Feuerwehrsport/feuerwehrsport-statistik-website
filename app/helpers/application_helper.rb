module ApplicationHelper
  include PageTitleHelper
  include LinksHelper
  include UIHelper
  include MapHelper
  include Helper::PositionSelectorHelper
  include DisciplineNamesAndImages
  include GenderNames
  include NumberedTeamNames
  include DatatableHelper
  include Registrations::RegistrationsHelper

  def h
    self
  end

  COMPETITOR_POSITION = {
    la: [
      'Maschinist',
      'A-Länge',
      'Saugkorb',
      'B-Schlauch',
      'Strahlrohr links',
      'Verteiler',
      'Strahlrohr rechts',
    ],
    gs: [
      'B-Schlauch',
      'Verteiler',
      'C-Schlauch',
      'Knoten',
      'D-Schlauch',
      'Läufer',
    ],
    fs: [
      { female: 'Leiterwand', male: 'Haus ' },
      { female: 'Hürde', male: 'Wand' },
      'Balken',
      'Feuer',
    ],
  }.freeze

  FINAL_NAMES = {
    -1 => 'Finale',
    -2 => 'Halbfinale',
    -3 => 'Viertelfinale',
    -4 => 'Achtelfinale',
  }.freeze

  def backend?
    controller.class.name.split('::').first == 'Backend'
  end

  def registrations?
    controller.class.name.split('::').first == 'Registrations'
  end

  def numbered_team_link(score, options = {})
    return '' if score.team.nil?

    link_to(numbered_team_name(score, options), score.team)
  end

  def final_name(final_count)
    FINAL_NAMES[final_count]
  end

  def competitor_position(discipline, position, gender)
    name = COMPETITOR_POSITION[discipline.to_sym][position - 1]
    name = name[gender.to_sym] if name.is_a? Hash
    name
  end

  def count_or_zero(count)
    count.to_i > 0 ? count : ''
  end

  def design_image(key, options = {})
    image_tag("design_images/#{key}.png", options)
  end

  def score_links(scores)
    scores.map do |score|
      link_to(score.second_time, score.competition, title: score.competition)
    end.join(', ').html_safe
  end

  def series_assessment_cup_participation(cup, row, html: true)
    result = row.participation_for_cup(cup)
    if result
      if html
        content_tag(:div, result.second_time_with_points, class: 'series-participation', data: { id: result.id })
      else
        result.second_time_with_points
      end
    else
      ''
    end
  end

  def image_link_to(image, title, *args)
    options = args.extract_options!
    image_options = options.delete(:image)
    title = "#{design_image(image, image_options)} #{title}".html_safe
    link_to(title, *args, options)
  end
end
