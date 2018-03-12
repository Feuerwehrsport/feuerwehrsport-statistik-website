require 'rails_helper'

describe Ipo::RegistrationMailer do
  describe '#new_notification' do
    let(:website) { create(:m3_website) }
    let(:registration) { create(:ipo_registration) }
    let(:mail) { described_class.configure(website, nil, :confirm, registration) }

    it 'renders the header information and assigns body' do
      expect(mail.subject).to eq 'Deine Anmeldung zum Inselpokal'
      expect(mail.to).to eq ['georf@georf.de']
      expect(mail.from).to eq ['info@kranbauer.de']

      expect_with_mailer_signature(
        "Dies ist eine Bestätigung für deine Anmeldung zum Inselpokal Poel.\n\n" \
        "Ansprechpartner:\n" \
        "Limbach, Georg\n" \
        "Rostock\n" \
        "0190 123456\n" \
        "georf@georf.de\n\n" \
        "Mannschaft:\n" \
        "Warin\n\n" \
        "Jugendmannschaft: Ja\n" \
        "Frauenmannschaft: Nein\n" \
        "Männermannschaft: Ja\n\n" \
        'Bitte informiere dich regelmäßig über die Webseite, ob du auf der Starterliste stehst. Diese E-Mail stellt ' \
        "keine Teilnahmegarantie dar.\n\n" \
        "Das Inselpokal Poel Team\n\n" \
        "http://www.inselpokal-poel.de/\n",
      )
    end
  end
end
