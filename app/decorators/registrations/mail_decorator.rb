# frozen_string_literal: true

class Registrations::MailDecorator < AppDecorator
  decorates_association :competition
  decorates_association :admin_user

  def team_receivers_count
    counted_name(Registrations::Team, object.teams.count)
  end

  def person_receivers_count
    counted_name(Registrations::Person, object.people.count)
  end

  private

  def counted_name(klass, count)
    "#{count} #{klass.model_name.human(count:)}"
  end
end
