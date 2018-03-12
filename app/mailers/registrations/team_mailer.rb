class Registrations::TeamMailer < ApplicationMailer
  def notification_to_creator(team)
    @team = team.decorate
    @competition = @team.competition
    @receiver = @team.admin_user
    mail(
      to: email_address_format(@receiver.email_address, @receiver),
      subject: "Deine Wettkampfanmeldung für #{@competition}",
    )
  end
end
