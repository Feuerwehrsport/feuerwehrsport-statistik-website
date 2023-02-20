# frozen_string_literal: true
class Ipo::RegistrationMailer < ApplicationMailer
  def confirm(registration)
    @registration = registration.decorate
    mail(to: email_address_format(registration.email_address, registration.name),
         subject: 'Deine Anmeldung zum Inselpokal')
  end
end
