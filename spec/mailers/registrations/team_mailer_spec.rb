# frozen_string_literal: true

require 'rails_helper'

describe Registrations::TeamMailer do
  let(:sender) { create(:admin_user) }
  let(:competition) { create(:registrations_competition, admin_user: sender) }
  let(:band) { create(:registrations_band, competition:) }
  let(:receiver) { create(:admin_user, login: build(:m3_login, email_address: 'receiver@example.com', name: 'hans')) }

  describe '#notification_to_creator' do
    let(:team) { create(:registrations_team, band:, admin_user: receiver) }
    let(:mail) { described_class.with(team:).notification_to_creator }

    it 'renders the header information and body' do
      expect(mail.subject).to eq "Deine Wettkampfanmeldung für D-Cup - #{I18n.l(Time.zone.today)}"
      expect(mail.header[:to].to_s).to eq('hans <receiver@example.com>')
      expect(mail.header[:from].to_s).to eq('Feuerwehrsport-Statistik <automailer@feuerwehrsport-statistik.de>')
      expect(mail.header[:cc].to_s).to eq('')
      expect(mail.header[:reply_to].to_s).to eq('')

      expect_with_mailer_signature <<~HEREDOC
        Du hast eine Mannschaft für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)} angemeldet.

        Weitere Informationen zu diesem Wettkampf findest du hier:
        http://test.host/registrations/competitions/#{competition.id}

        Du kannst deine Anmeldung auch weiterhin bearbeiten oder wieder entfernen. Nutze dafür die folgende Seite:
        http://test.host/registrations/bands/#{band.id}/teams/#{team.id}

        Mannschaft: FF Mannschaft 1
        Wertungsgruppe: Männer
      HEREDOC
    end
  end
end
