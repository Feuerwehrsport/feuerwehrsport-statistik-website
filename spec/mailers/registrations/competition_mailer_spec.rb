require 'rails_helper'

describe Registrations::CompetitionMailer do
  let(:website) { create(:m3_website) }
  let(:sender) { create(:admin_user) }
  let(:competition) { create(:registrations_competition, admin_user: sender) }
  let(:receiver) { create(:admin_user, login: build(:m3_login, email_address: 'receiver@example.com', name: 'hans')) }

  describe '#new_team_registered' do
    let(:team) { create(:registrations_team, competition: competition, admin_user: receiver) }
    let(:mail) { described_class.configure(website, nil, :new_team_registered, team) }

    it 'renders the header information and body' do
      expect(mail.subject).to eq "Neue Wettkampfanmeldung für D-Cup - #{I18n.l(Time.zone.today)}"
      expect(mail.to).to eq(['admin_user@example.com'])
      expect(mail.from).to eq(['info@kranbauer.de'])

      expect_with_mailer_signature(
        "Es wurde eine neue Mannschaft für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)} angemeldet.\n" \
        "\n" \
        "Weitere Informationen zu deinem Wettkampf findest du hier:\n" \
        "http://www.kranbauer.de/registrations/competitions/#{competition.id}\n" \
        "\n" \
        "Mannschaft: FF Mannschaft 1\n" \
        "Geschlecht: männlich\n" \
        "Absender: hans\n" \
        "\n" \
        "Bitte beachte, dass du über weitere Änderungen bezüglich dieser Mannschaft nicht separat informiert wirst.\n",
      )
    end
  end
  describe '#new_person_registered' do
    let(:person) { create(:registrations_person, competition: competition, admin_user: receiver) }
    let(:mail) { described_class.configure(website, nil, :new_person_registered, person) }

    it 'renders the header information and body' do
      expect(mail.subject).to eq "Neue Wettkampfanmeldung für D-Cup - #{I18n.l(Time.zone.today)}"
      expect(mail.to).to eq(['admin_user@example.com'])
      expect(mail.from).to eq(['info@kranbauer.de'])

      expect_with_mailer_signature(
        "Es wurde ein neuer Einzelstarter für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)} angemeldet.\n" \
        "\n" \
        "Weitere Informationen zu deinem Wettkampf findest du hier:\n" \
        "http://www.kranbauer.de/registrations/competitions/#{competition.id}\n" \
        "\n" \
        "Wettkämpfer: Alfred Meier\n" \
        "Geschlecht: männlich\n" \
        "Absender: hans\n" \
        "\n" \
        'Bitte beachte, dass du über weitere Änderungen bezüglich dieses Einzelstarters ' \
        "nicht separat informiert wirst.\n",
      )
    end
  end

  describe '#news' do
    let(:resource) { create(:registrations_team, competition: competition, admin_user: receiver) }
    let(:add_registration_file) { true }
    let(:mail) do
      described_class.configure(website, nil, :news, resource, competition, 'subject', 'text',
                                add_registration_file, sender)
    end

    it 'renders the header information' do
      expect(mail.subject).to eq 'subject'
      expect(mail.to).to eq(['receiver@example.com'])
      expect(mail.from).to eq(['info@kranbauer.de'])
    end

    context 'when team with attachment' do
      it 'assigns body and attachment' do
        expect_with_mailer_signature_and_attachments(
          "Hallo hans,\n" \
          "\n" \
          "es folgt ein Hinweis von admin user für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)}:\n" \
          "\n" \
          "text\n", [
            content_type: 'application/pdf', filename: 'anmeldung.pdf',
          ]
        )
      end
    end

    context 'when person without attachment' do
      let(:resource) { create(:registrations_person, competition: competition) }
      let(:add_registration_file) { false }

      it 'assigns only body' do
        expect_with_mailer_signature(
          "Hallo admin user,\n" \
          "\n" \
          "es folgt ein Hinweis von admin user für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)}:\n" \
          "\n" \
          "text\n",
        )
      end
    end
  end
end
