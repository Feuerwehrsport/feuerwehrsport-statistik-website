class Registrations::PersonDecorator < AppDecorator
  decorates_association :team
  decorates_association :competition
  decorates_association :admin_user
end
