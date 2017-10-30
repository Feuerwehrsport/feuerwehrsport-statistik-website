class ApplicationMailer < M3::ApplicationMailer
  layout 'mailer'
  add_template_helper(ApplicationHelper)
end
