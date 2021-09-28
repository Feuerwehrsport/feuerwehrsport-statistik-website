# frozen_string_literal: true

class M3::LoginMailer < ApplicationMailer
  def change_email_address(login)
    @login = login
    mail(to: email_address_format(login.changed_email_address, login.name))
  end

  def verify(login)
    @login = login
    mail(to: email_address_format(login.email_address, login.name))
  end

  def password_reset(login)
    @login = login
    mail(to: email_address_format(login.email_address, login.name))
  end
end
