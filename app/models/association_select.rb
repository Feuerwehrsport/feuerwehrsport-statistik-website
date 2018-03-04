class AssociationSelect
  def initialize(ability)
    @ability = ability
  end

  def competition(search_term, ids, limit: 10)
    rel = Competition.all.limit(limit).accessible_by(@ability, :index)
    rel = rel.search(search_term) if search_term.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, c.date, "##{c.id}"] }
  end

  def team(search_term, ids, limit: 10)
    rel = Team.index_order.limit(limit).accessible_by(@ability, :index)
    rel = rel.where_name_like(search_term) if search_term.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, c.full_state, "##{c.id}"] }
  end

  def place(search_term, ids, limit: 10)
    rel = Place.all.limit(limit).accessible_by(@ability, :index)
    rel = rel.search(search_term) if search_term.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, nil, "##{c.id}"] }
  end

  def event(search_term, ids, limit: 10)
    rel = Event.all.limit(limit).accessible_by(@ability, :index)
    rel = rel.search(search_term) if search_term.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, nil, "##{c.id}"] }
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
    rel.decorate.map { |c| [c.id, c.to_s, c.gender_translated, "##{c.id}"] }
  end

  def group_score_category(search_term, ids, limit: 10)
    rel = GroupScoreCategory.limit(limit).accessible_by(@ability, :index)
    if search_term.present?
      competitions = Competition.all.accessible_by(@ability, :index).search(search_term)
      rel = rel.where(competition_id: competitions.select(:id))
    end
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.with_competition, c.discipline, "##{c.id}"] }
  end

  def admin_user(search_term, ids, limit: 10)
    rel = AdminUser.limit(limit).accessible_by(@ability, :index)
    rel = rel.where_name_like(search_term) if search_term.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, c.role, "##{c.id}"] }
  end

  def group_score(search_term, ids, limit: 10)
    rel = GroupScore.limit(limit).accessible_by(@ability, :index)
    name_search_team = search_term.try(:gsub, /\d/, '')
    time_search_team = search_term.try(:gsub, /[^\d]/, '')
    if name_search_team.present?
      teams = Team.all.accessible_by(@ability, :index).where_name_like(name_search_team)
      rel = rel.where(team_id: teams.select(:id))
    end
    rel = rel.where_time_like(time_search_team) if time_search_team.present?
    rel = rel.where(id: ids) if ids
    rel.decorate.map { |c| [c.id, c.to_s, nil, "##{c.id}"] }
  end
end
