class ActionManager::RegistrationsCompetitionsAddPersonActionDecorator < ActionManager::ActionDecorator
  def url
    h.new_registrations_competition_person_path(resource)
  end
end
