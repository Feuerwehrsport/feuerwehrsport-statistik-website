class ImportRequestMailer < ApplicationMailer
  def new_request(import_request)
    @import_request = import_request.decorate
    to = AdminUser.change_request_notification_receiver.where.not(id: import_request.admin_user_id).map(&:named_email_address)
    mail(to: to, subject: 'Import-Anfrage bei Feuerwehrsport-Statistik')
  end
end
