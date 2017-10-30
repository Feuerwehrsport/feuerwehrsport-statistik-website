class Registrations::TeamMailer < ApplicationMailer
  def notification_to_creator(team)
    @team = team.decorate
    @competition = @team.competition
    @admin_user = @team.admin_user
    mail(to: @admin_user.named_email_address, subject: "Deine Wettkampfanmeldung für #{@competition}")
  end
end
