module ApplicationHelper
  include PageTitleHelper
  include LinksHelper
  include UIHelper
  include MapHelper
  include Helper::PositionSelectorHelper
  include Helper::NationHelper
  include Helper::PrawnHelper
  include DisciplineNamesAndImages
  include GenderNames

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

  def numbered_team_name(score, options = {})
    return '' if score.team.blank?
    number_name = begin
      if score.team_number == 0
        ' E'
      elsif score.team_number <= -1 && score.team_number >= -4
        ' F'
      elsif score.team_number == -5
        ' A'
      else
        options = {
          competition_id: score.try(:competition).try(:id),
          team_id: score.try(:team_id),
          gender: score.try(:gender) || score.try(:person).try(:gender),
        }.merge(options)
        c = CompetitionTeamNumber
            .gender(options[:gender])
            .where(competition_id: options[:competition_id], team_id: options[:team_id])
            .distinct.count(:team_number)
        c > 1 ? " #{score.team_number}" : ''
      end
    end
    run = score.try(:run).present? ? " #{score.run}" : ''
    score.team.shortcut + number_name + run
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

  def errors_on?(*attributes)
    attributes.any? do |attribute|
      resource_instance.errors[attribute].present?
    end
  end

  def image_link_to(image, title, *args)
    options = args.extract_options!
    image_options = options.delete(:image)
    title = "#{design_image(image, image_options)} #{title}".html_safe
    link_to(title, *args, options)
  end
end
