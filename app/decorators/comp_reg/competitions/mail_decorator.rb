class CompReg::Competitions::MailDecorator < ApplicationDecorator
  decorates_association :competition
  decorates_association :admin_user
end