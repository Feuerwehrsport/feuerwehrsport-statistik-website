class ActionManager::RegistrationsCompetitionsAddTeamActionDecorator < ActionManager::ActionDecorator
  def url
    h.new_registrations_competition_team_path(resource)
  end
end
