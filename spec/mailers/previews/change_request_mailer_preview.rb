# Preview all emails at http://localhost:3000/rails/mailers/change_request_mailer
class ChangeRequestMailerPreview < ActionMailer::Preview
  def new_notification
    ChangeRequestMailer.new_notification(ChangeRequest.first)
  end
end
