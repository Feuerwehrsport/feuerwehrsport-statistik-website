# frozen_string_literal: true
class Registrations::CompetitionMailer < ApplicationMailer
  def new_team_registered(team)
    @team = team.decorate
    @competition = @team.competition
    @receiver = @competition.admin_user
    mail(
      to: email_address_format(@receiver.email_address, @receiver),
      subject: "Neue Wettkampfanmeldung für #{@competition}",
    )
  end

  def new_person_registered(person)
    @person = person.decorate
    @competition = @person.competition
    @receiver = @competition.admin_user
    mail(
      to: email_address_format(@receiver.email_address, @receiver),
      subject: "Neue Wettkampfanmeldung für #{@competition}",
    )
  end

  def news(resource, competition, subject, text, add_registration_file, sender)
    @resource = resource.decorate
    @sender = sender.decorate
    @competition = competition.decorate
    @text = text

    if add_registration_file
      attachments['anmeldung.pdf'] = {
        mime_type: 'application/pdf',
        content: Registrations::Teams::Pdf.build(resource).bytestream,
      }
    end

    mail(
      to: email_address_format(resource.admin_user.email_address, resource.admin_user.name),
      subject: subject,
      reply_to: email_address_format(sender.email_address, sender.name),
      cc: email_address_format(sender.email_address, sender.name),
    )
  end
end
