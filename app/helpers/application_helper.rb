module ApplicationHelper
  include LinksHelper
  include UIHelper
  include MapHelper
  include Helper::PositionSelectorHelper
  include Helper::NationHelper

  COMPETITOR_POSITION = {
    la: [
      'Maschinist',
      'A-Länge',
      'Saugkorb',
      'B-Schlauch',
      'Strahlrohr links',
      'Verteiler',
      'Strahlrohr rechts'
    ],
    gs: [
      'B-Schlauch',
      'Verteiler',
      'C-Schlauch',
      'Knoten',
      'D-Schlauch',
      'Läufer'
    ],
    fs: [
      { female: 'Leiterwand', male: 'Haus '},
      { female: 'Hürde', male: 'Wand' },
      'Balken',
      'Feuer'
    ]
  }

  FINAL_NAMES = {
    -2 => "Finale",
    -3 => "Halbfinale",
    -4 => "Viertelfinale",
    -5 => "Achtelfinale",
  }

  def backend?
    controller.class.name.split("::").first=="Backend"
  end

  def numbered_team_name(score, options={})
    number_name = begin
      if score.team_number == -1
        " E"   
      elsif score.team_number <= -2 && score.team_number >= -5
        ' F'
      elsif score.team_number == -6
        ' A'
      else
        options = { 
          competition_id: score.try(:competition).try(:id), 
          team_id: score.try(:team_id),
          gender: score.try(:gender) || score.try(:person).try(:gender),
        }.merge(options)
        c = CompetitionTeamNumber.
          gender(options[:gender]).
          where(competition_id: options[:competition_id], team_id: options[:team_id]).
          distinct.count(:team_number)
        c > 1 ? " #{score.team_number + 1}" : ""
      end
    end
    run = score.try(:run).present? ? " #{score.run}" : ""
    score.team.shortcut + number_name + run
  end

  def numbered_team_link(score, options={})
    link_to(numbered_team_name(score, options), score.team)
  end

  def g(gender)
    t("gender.#{normalize_gender(gender)}")
  end

  def g_symbol(gender)
    t("gender.#{normalize_gender(gender)}_symbol")
  end

  def g_color(gender)
    t("gender.#{normalize_gender(gender)}_color")
  end

  def discipline_name(discipline)
    t("discipline.#{discipline}")
  end

  def discipline_image_name_short(discipline, gender=nil)
    text = "#{discipline_image(discipline)} #{discipline_name_short(discipline)}"
    text += " #{g_symbol(gender)}" if gender.present?
    text.html_safe
  end

  def discipline_name_short(discipline)
    discipline.to_s.upcase
  end

  def discipline_image(discipline, options={})
    options = { width: 20, title: discipline_name(discipline) }.merge(options)
    image_tag(asset_path("disciplines/#{discipline}.png"), options)
  end

  def discipline_color(discipline)
    t("discipline.#{discipline}_color")
  end

  def group_discipline?(discipline)
    discipline.to_sym.in? [:gs, :fs, :la]
  end

  def final_name(final_count)
    FINAL_NAMES[final_count]
  end

  def competitor_position(discipline, position, gender)
    name = COMPETITOR_POSITION[discipline.to_sym][position - 1]
    name = name[gender.to_sym] if name.is_a? Hash
    name
  end

  def normalize_gender(gender)
    gender = gender == 1 ? :male : :female if gender.in? [0, 1]
    gender
  end

  def count_or_zero(count)
    count.to_i > 0 ? count : ""
  end

  def design_image(key, options={})
    image_tag(asset_path("design_images/#{key}.png"), options)
  end
end
