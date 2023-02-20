# frozen_string_literal: true

require 'rails_helper'

describe Ipo::RegistrationMailer do
  describe '#new_notification' do
    let(:website) { create(:m3_website) }
    let(:registration) { create(:ipo_registration) }
    let(:mail) { described_class.configure(website, nil, :confirm, registration) }

    it 'renders the header information and body' do
      expect(mail.subject).to eq 'Deine Anmeldung zum Inselpokal'
      expect(mail.header[:to].to_s).to eq('"Limbach, Georg" <georf@georf.de>')
      expect(mail.header[:from].to_s).to eq('Kranbauer <info@kranbauer.de>')
      expect(mail.header[:cc].to_s).to eq('')
      expect(mail.header[:reply_to].to_s).to eq('')

      expect_with_mailer_signature <<~HEREDOC
        Dies ist eine Bestätigung für deine Anmeldung zum Inselpokal Poel.

        Ansprechpartner:
        Limbach, Georg
        Rostock
        0190 123456
        georf@georf.de

        Mannschaft:
        Warin

        Jugendmannschaft: Ja
        Frauenmannschaft: Nein
        Männermannschaft: Ja

        Bitte informiere dich regelmäßig über die Webseite, ob du auf der Starterliste stehst. Diese E-Mail stellt keine Teilnahmegarantie dar.

        Das Inselpokal Poel Team

        http://www.inselpokal-poel.de/
      HEREDOC
    end
  end
end
