module LinksHelper
  def competition_link(competition, options={})
    type = options.delete(:type) || :to_s
    options = options.merge(title: "Details zu diesem Wettkampf anzeigen")
    link_to(competition.send(type), competition, options)
  end

  def person_link(person, options={})
    type = options.delete(:type) || :to_s
    options = options.merge(title: "Details zu #{person.full_name} anzeigen")
    link_to(person.send(type), person, options)
  end
end