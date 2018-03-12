require 'rails_helper'

describe Registrations::TeamMailer do
  let(:website) { create(:m3_website) }
  let(:sender) { create(:admin_user) }
  let(:competition) { create(:registrations_competition, admin_user: sender) }
  let(:receiver) { create(:admin_user, login: build(:m3_login, email_address: 'receiver@example.com', name: 'hans')) }

  describe '#notification_to_creator' do
    let(:team) { create(:registrations_team, competition: competition, admin_user: receiver) }
    let(:mail) { described_class.configure(website, nil, :notification_to_creator, team) }

    it 'renders the header information and body' do
      expect(mail.subject).to eq "Deine Wettkampfanmeldung für D-Cup - #{I18n.l(Time.zone.today)}"
      expect(mail.to).to eq(['receiver@example.com'])
      expect(mail.from).to eq(['info@kranbauer.de'])

      expect_with_mailer_signature(
        "Du hast eine Mannschaft für den Wettkampf D-Cup - #{I18n.l(Time.zone.today)} angemeldet.\n" \
        "\n" \
        "Weitere Informationen zu diesem Wettkampf findest du hier:\n" \
        "http://www.kranbauer.de/registrations/competitions/#{competition.id}\n" \
        "\n" \
        "Du kannst deine Anmeldung auch weiterhin bearbeiten oder wieder entfernen. Nutze dafür die folgende Seite:\n" \
        "http://www.kranbauer.de/registrations/competitions/#{competition.id}/teams/#{team.id}\n" \
        "\n" \
        "Mannschaft: FF Mannschaft 1\n" \
        "Geschlecht: männlich\n",
      )
    end
  end
end
