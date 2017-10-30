class ImportRequestMailer < ApplicationMailer
  def new_request(import_request)
    @import_request = import_request.decorate
    to = AdminUser.change_request_notification_receiver.where.not(id: import_request.admin_user_id).map do |admin_user|
      email_address_format(admin_user.email_address, admin_user.name)
    end
    mail(to: to, subject: 'Import-Anfrage bei Feuerwehrsport-Statistik')
  end
end
