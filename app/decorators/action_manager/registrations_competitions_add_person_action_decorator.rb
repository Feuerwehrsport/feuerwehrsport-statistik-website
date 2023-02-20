# frozen_string_literal: true

class ActionManager::RegistrationsCompetitionsAddPersonActionDecorator < ActionManager::ActionDecorator
  def url
    h.new_registrations_competition_person_creation_path(resource)
  end
end
