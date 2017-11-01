class AssociationSelect
  def initialize(ability)
    @ability = ability
  end

  def competition(search_term, ids, limit: 10)
    rel = Competition.all.limit(limit).accessible_by(@ability, :index)
    rel = rel.search(search_term) if search_term.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, c.date, nil] }
  end

  def team(search_term, ids, limit: 10)
    rel = Team.all.limit(limit).accessible_by(@ability, :index)
    rel = rel.where_name_like(search_term) if search_term.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, c.full_state, nil] }
  end

  def score(search_term, ids, limit: 10)
    rel = Score.all.limit(limit * 2).accessible_by(@ability, :index)
    name_search_team = search_term.try(:gsub, /\d/, '')
    time_search_team = search_term.try(:gsub, /[^\d]/, '')
    if name_search_team.present?
      people = Person.all.accessible_by(@ability, :index).where_name_like(name_search_team)
      rel = rel.where(person_id: people.select(:id))
    end
    rel = rel.where_time_like(time_search_team) if time_search_team.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, c.competition.to_s, c.translated_discipline_name] }
  end

  def person(search_term, ids, limit: 10)
    rel = Person.all.limit(limit).accessible_by(@ability, :index)
    rel = rel.where_name_like(search_term) if search_term.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, c.gender_translated, nil] }
  end
end