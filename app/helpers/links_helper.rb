module LinksHelper
  def competition_link(competition, options={})
    type = options.delete(:type) || :to_s
    options = options.merge(title: "Details zu diesem Wettkampf anzeigen")
    link_to(competition.send(type), competition, options)
  end

  def event_link(event, options={})
    type = options.delete(:type) || :to_s
    options = options.merge(title: "Details zu diesem Wettkampftyp anzeigen")
    link_to(event.send(type), event, options)
  end

  def place_link(place, options={})
    type = options.delete(:type) || :to_s
    options = options.merge(title: "Details zu diesem Ort anzeigen")
    link_to(place.send(type), place, options)
  end

  def person_link(person, options={})
    options = options.dup
    type = options.delete(:type) || :to_s
    options = options.merge(title: "Details zu #{person.full_name} anzeigen")
    link_to(person.send(type), person, options)
  end

  def team_link(team, options={})
    type = options.delete(:type) || :to_s
    options = options.merge(title: "Details zu #{team.name} anzeigen")
    link_to(team.send(type), team, options)
  end

  def year_link(year, options={})
    type = options.delete(:type) || :to_s
    options = options.merge(title: "Details zu dem Jahr #{year.to_s} anzeigen")
    link_to(year.send(type), year, options)
  end

  def contact_link(label)
    link_to(label, impressum_path, title: "Kontakt und Impressum")
  end
end