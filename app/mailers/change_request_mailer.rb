class ChangeRequestMailer < ApplicationMailer
  def new_notification(change_request)
    @change_request = change_request.decorate
    to = AdminUser.change_request_notification_receiver.where.not(id: change_request.admin_user_id).map(&:named_email_address)
    mail(to: to, subject: 'Fehler bei Feuerwehrsport-Statistik')
  end
end
