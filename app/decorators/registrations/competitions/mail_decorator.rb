class Registrations::Competitions::MailDecorator < AppDecorator
  decorates_association :competition
  decorates_association :admin_user
end
