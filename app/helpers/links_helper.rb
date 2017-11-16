module LinksHelper
  def competition_link(competition, options = {})
    options = options.merge(title: 'Details zu diesem Wettkampf anzeigen')
    details_link(competition, options)
  end

  def event_link(event, options = {})
    options = options.merge(title: 'Details zu diesem Wettkampftyp anzeigen')
    details_link(event, options)
  end

  def place_link(place, options = {})
    options = options.merge(title: 'Details zu diesem Wettkampfort anzeigen')
    details_link(place, options)
  end

  def person_link(person, options = {})
    options = options.merge(title: "Details zu #{person.try(:full_name)} anzeigen")
    details_link(person, options)
  end

  def team_link(team, options = {})
    options = options.merge(title: "Details zu #{team.try(:name)} anzeigen")
    details_link(team, options)
  end

  def year_link(year, options = {})
    options = options.merge(title: "Details zu dem Jahr #{year} anzeigen")
    details_link(year, options)
  end

  def contact_link(label)
    link_to(label, impressum_path, title: 'Kontakt und Impressum')
  end

  def details_link(object, options)
    type = options.delete(:type) || :to_s
    object.send(type).blank? ? '' : link_to(object.send(type), object, options)
  end

  def current_wko_link(label)
    wko_2016_link(label, title: 'Aktuelle Wettkampfordnung vom Jahr 2016')
  end

  def wko_2016_link(label, options = {})
    link_to(label, "#{root_path}dfv-wko-2016.pdf", options.reverse_merge(title: 'Wettkampfordnung vom Jahr 2016'))
  end

  def wko_2012_link(label, options = {})
    link_to(label, "#{root_path}dfv-wko-2012.pdf", options.reverse_merge(title: 'Wettkampfordnung vom Jahr 2012'))
  end
end
