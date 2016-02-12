class CompReg::PersonMailer < ApplicationMailer
  def notification_to_creator(person)
    @person = person.decorate
    @competition = @person.competition
    @admin_user = @person.admin_user
    mail(to: @admin_user.named_email_address, subject: "Deine Wettkampfanmeldung für #{@competition}")
  end
end
