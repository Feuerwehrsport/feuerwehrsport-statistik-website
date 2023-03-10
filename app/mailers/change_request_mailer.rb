# frozen_string_literal: true

class ChangeRequestMailer < ApplicationMailer
  def new_notification
    change_request = params[:change_request]
    @change_request = change_request.decorate
    to = AdminUser.change_request_notification_receiver.where.not(id: change_request.admin_user_id).map do |admin_user|
      email_address_format(admin_user.email_address, admin_user.name)
    end
    return ActionMailer::Base::NullMail.new if to.blank?

    mail(to:, subject: 'Fehler bei Feuerwehrsport-Statistik')
  end
end
