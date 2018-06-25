class Registrations::TeamAssessmentParticipationDecorator < AppDecorator
  decorates_association :assessment
  decorates_association :team

  def to_s
    team.with_number
  end
end
