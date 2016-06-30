class ApplicationMailer < ActionMailer::Base
  layout "mailer"
  add_template_helper(ApplicationHelper)
end
