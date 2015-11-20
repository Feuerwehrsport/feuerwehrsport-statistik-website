module LinksHelper
  def competition_link(competition, options={})
    type = options.delete(:type) || :to_s
    options = options.merge(title: "Details zu diesem Wettkampf anzeigen")
    link_to(competition.send(type), competition, options)
  end
end