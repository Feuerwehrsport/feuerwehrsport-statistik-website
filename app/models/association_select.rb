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
end
