# frozen_string_literal: true

class Registrations::TeamAssessmentParticipation < Registrations::AssessmentParticipation
  belongs_to :team, class_name: 'Registrations::Team'
end
