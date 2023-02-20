# frozen_string_literal: true
class ChangeRequestMailer < ApplicationMailer
  def new_notification(change_request)
    @change_request = change_request.decorate
    to = AdminUser.change_request_notification_receiver.where.not(id: change_request.admin_user_id).map(&:email_address)
    return ActionMailer::Base::NullMail.new if to.blank?

    mail(to: to, subject: 'Fehler bei Feuerwehrsport-Statistik')
  end
end
