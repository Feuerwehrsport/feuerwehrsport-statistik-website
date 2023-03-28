# frozen_string_literal: true

class Registrations::MailDecorator < AppDecorator
  decorates_association :competition
  decorates_association :admin_user

  def team_receivers_count
    counted_name(Registrations::Team, object.competition.bands.sum { |b| b.teams.count })
  end

  def person_receivers_count
    counted_name(Registrations::Person, object.competition.bands.sum { |b| b.people.count })
  end

  private

  def counted_name(klass, count)
    "#{count} #{klass.model_name.human(count:)}"
  end
end
