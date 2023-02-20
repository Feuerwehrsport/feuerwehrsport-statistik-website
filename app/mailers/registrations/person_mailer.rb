# frozen_string_literal: true
class Registrations::PersonMailer < ApplicationMailer
  def notification_to_creator(person)
    @person = person.decorate
    @competition = @person.competition
    @receiver = @person.admin_user
    mail(
      to: email_address_format(@receiver.email_address, @receiver),
      subject: "Deine Wettkampfanmeldung für #{@competition}",
    )
  end
end
