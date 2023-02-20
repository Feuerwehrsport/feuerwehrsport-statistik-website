# frozen_string_literal: true

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
      expect(mail.header[:to].to_s).to eq('admin user <admin_user@example.com>')
      expect(mail.header[:from].to_s).to eq('Kranbauer <info@kranbauer.de>')
      expect(mail.header[:cc].to_s).to eq('')
      expect(mail.header[:reply_to].to_s).to eq('')

      expect_with_mailer_signature <<~HEREDOC
        Es wurde eine neue Mannschaft für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)} angemeldet.

        Weitere Informationen zu deinem Wettkampf findest du hier:
        http://www.kranbauer.de/registrations/competitions/#{competition.id}

        Mannschaft: FF Mannschaft 1
        Geschlecht: männlich
        Absender: hans

        Bitte beachte, dass du über weitere Änderungen bezüglich dieser Mannschaft nicht separat informiert wirst.
      HEREDOC
    end
  end

  describe '#new_person_registered' do
    let(:person) { create(:registrations_person, competition: competition, admin_user: receiver) }
    let(:mail) { described_class.configure(website, nil, :new_person_registered, person) }

    it 'renders the header information and body' do
      expect(mail.subject).to eq "Neue Wettkampfanmeldung für D-Cup - #{I18n.l(Time.zone.today)}"
      expect(mail.header[:to].to_s).to eq('admin user <admin_user@example.com>')
      expect(mail.header[:from].to_s).to eq('Kranbauer <info@kranbauer.de>')
      expect(mail.header[:cc].to_s).to eq('')
      expect(mail.header[:reply_to].to_s).to eq('')

      expect_with_mailer_signature <<~HEREDOC
        Es wurde ein neuer Einzelstarter für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)} angemeldet.

        Weitere Informationen zu deinem Wettkampf findest du hier:
        http://www.kranbauer.de/registrations/competitions/#{competition.id}

        Wettkämpfer: Alfred Meier
        Geschlecht: männlich
        Absender: hans

        Bitte beachte, dass du über weitere Änderungen bezüglich dieses Einzelstarters nicht separat informiert wirst.
      HEREDOC
    end
  end

  describe '#news' do
    let(:resource) { create(:registrations_team, competition: competition, admin_user: receiver) }
    let(:add_registration_file) { true }
    let(:mail) do
      described_class.configure(website, nil, :news, resource, competition, 'subject', 'text',
                                add_registration_file, sender)
    end

    it 'renders the header information and body' do
      expect(mail.subject).to eq 'subject'
      expect(mail.header[:to].to_s).to eq('hans <receiver@example.com>')
      expect(mail.header[:from].to_s).to eq('Kranbauer <info@kranbauer.de>')
      expect(mail.header[:cc].to_s).to eq('admin user <admin_user@example.com>')
      expect(mail.header[:reply_to].to_s).to eq('admin user <admin_user@example.com>')

      expect_with_mailer_signature_and_attachments([
                                                     content_type: 'application/pdf', filename: 'anmeldung.pdf',
                                                   ], <<~HEREDOC
                                                     Hallo hans,

                                                     es folgt ein Hinweis von admin user für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)}:

                                                     text
                                                   HEREDOC

      )
    end

    context 'when person without attachment' do
      let(:resource) { create(:registrations_person, competition: competition) }
      let(:add_registration_file) { false }

      it 'assigns only body' do
        expect(mail.subject).to eq 'subject'
        expect(mail.header[:to].to_s).to eq('admin user <admin_user@example.com>')
        expect(mail.header[:from].to_s).to eq('Kranbauer <info@kranbauer.de>')
        expect(mail.header[:cc].to_s).to eq('admin user <admin_user@example.com>')
        expect(mail.header[:reply_to].to_s).to eq('admin user <admin_user@example.com>')

        expect_with_mailer_signature <<~HEREDOC
          Hallo admin user,

          es folgt ein Hinweis von admin user für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)}:

          text
        HEREDOC
      end
    end
  end
end
