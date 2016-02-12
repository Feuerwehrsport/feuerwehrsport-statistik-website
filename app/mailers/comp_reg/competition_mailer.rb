class CompReg::CompetitionMailer < ApplicationMailer
  def new_team_registered(team)
    @team = team.decorate
    @competition = @team.competition
    @admin_user = @competition.admin_user
    mail(to: @admin_user.named_email_address, subject: "Neue Wettkampfanmeldung für #{@competition}")
  end

  def new_person_registered(person)
    @person = person.decorate
    @competition = @person.competition
    @admin_user = @competition.admin_user
    mail(to: @admin_user.named_email_address, subject: "Neue Wettkampfanmeldung für #{@competition}")
  end
end
