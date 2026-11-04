# frozen_string_literal: true

require 'rails_helper'

describe LoginMailer do
  let(:login) do
    create(:m3_login, email_address: 'alfred@example.com', name: "Alfred\r\nMeier",
                      changed_email_address: 'new@example.com')
  end

  shared_examples 'a login mail' do |to:|
    it 'renders the header information' do
      expect(mail.header[:to].to_s).to eq to
      expect(mail.header[:from].to_s).to eq 'Feuerwehrsport-Statistik <automailer@feuerwehrsport-statistik.de>'
      expect(mail.header[:cc].to_s).to eq ''
      expect(mail.header[:reply_to].to_s).to eq ''
    end
  end

  describe '#verify' do
    let(:mail) { described_class.with(login:).verify }

    it_behaves_like 'a login mail', to: 'AlfredMeier <alfred@example.com>'

    it 'renders the body' do
      expect_with_mailer_signature(
        "Um Ihre E-Mail-Adresse zu bestätigen, rufen Sie bitte die nachfolgende URL auf:\n" \
        "\n" \
        "http://test.host/verify_login/#{login.verify_token}\n",
      )
    end

    it 'uses the translated subject' do
      expect(mail.subject).to eq 'Validierung der E-Mail-Adresse'
    end
  end

  describe '#password_reset' do
    let(:mail) { described_class.with(login:).password_reset }

    it_behaves_like 'a login mail', to: 'AlfredMeier <alfred@example.com>'

    it 'renders the body' do
      expect_with_mailer_signature(
        "Um Ihr Passwort zu ändern, rufen Sie bitte die nachfolgende URL auf:\n" \
        "\n" \
        "http://test.host/password_reset/#{login.password_reset_token}/edit\n" \
        "\n" \
        'Diese URL ist 24 Stunden gültig. Sollte Sie diese E-Mail nicht beauftragt haben, ' \
        "können Sie diese einfach ignorieren.\n",
      )
    end

    it 'uses the translated subject' do
      expect(mail.subject).to eq 'Zurücksetzen des Passworts'
    end
  end

  describe '#change_email_address' do
    let(:mail) { described_class.with(login:).change_email_address }

    it_behaves_like 'a login mail', to: 'AlfredMeier <new@example.com>'

    it 'renders the body' do
      expect_with_mailer_signature(
        "Um Ihre E-Mail-Adresse zu ändern, rufen Sie bitte die nachfolgende URL auf:\n" \
        "\n" \
        "http://test.host/changed_email_addresses/#{login.changed_email_address_token}/edit\n" \
        "\n" \
        'Diese URL ist 24 Stunden gültig. Sollten Sie diese E-Mail nicht beauftragt haben, ' \
        "können Sie diese einfach ignorieren.\n",
      )
    end

    it 'uses the translated subject' do
      expect(mail.subject).to eq 'Änderung der E-Mail-Adresse'
    end
  end

  describe 'without name' do
    let(:login) { create(:m3_login, email_address: 'alfred@example.com', name: '') }
    let(:mail) { described_class.with(login:).verify }

    it 'uses plain email address' do
      expect(mail.header[:to].to_s).to eq 'alfred@example.com'
    end
  end
end
