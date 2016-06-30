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

  def team_news(competition_mail, team)
    @team = team.decorate
    @competition_mail = competition_mail.decorate

    if competition_mail.add_registration_file?
      pdf = Prawn::Document.new(page_size: 'A4')
      @team.team_pdf_overview(pdf, footer: true)
      attachments['anmeldung.pdf'] = { mime_type: 'application/pdf', content: pdf.render }
    end

    mail(to: @team.admin_user.named_email_address, subject: @competition_mail.subject)
  end

  def person_news(competition_mail, person)
    @person = person.decorate
    @competition_mail = competition_mail.decorate
    mail(to: @person.admin_user.named_email_address, subject: @competition_mail.subject)
  end
end
