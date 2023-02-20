# frozen_string_literal: true

class Registrations::PersonDecorator < AppDecorator
  decorates_association :team
  decorates_association :competition
  decorates_association :admin_user
  localizes_gender

  delegate :to_s, to: :full_name

  def full_name
    "#{first_name} #{last_name}"
  end

  def short_name
    "#{first_name[0]}. #{last_name}"
  end
end
