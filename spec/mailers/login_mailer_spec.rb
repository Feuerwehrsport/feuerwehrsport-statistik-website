# frozen_string_literal: true

require 'rails_helper'

describe LoginMailer do
  let(:login) do
    create(:login, email_address: 'alfred@example.com', name: "Alfred\r\nMeier",
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

    it 'renders the body with a valid verification link' do
      login.update!(verified_at: nil)
      token = mail.body.to_s[%r{http://test.host/verify_login/(\S+)}, 1]
      expect(mail.body.to_s).to start_with('Um Ihre E-Mail-Adresse zu bestätigen')
      expect(Login.find_by_token_for(:verification, token)).to eq login
    end

    it 'uses the translated subject' do
      expect(mail.subject).to eq 'Validierung der E-Mail-Adresse'
    end
  end

  describe '#password_reset' do
    let(:mail) { described_class.with(login:).password_reset }

    it_behaves_like 'a login mail', to: 'AlfredMeier <alfred@example.com>'

    it 'renders the body with a valid reset link' do
      token = mail.body.to_s[%r{http://test.host/password_reset/(\S+)/edit}, 1]
      expect(mail.body.to_s).to include('Diese URL ist 24 Stunden gültig.')
      expect(Login.find_by_password_reset_token(token)).to eq login
    end

    it 'uses the translated subject' do
      expect(mail.subject).to eq 'Zurücksetzen des Passworts'
    end
  end

  describe '#change_email_address' do
    let(:mail) { described_class.with(login:).change_email_address }

    it_behaves_like 'a login mail', to: 'AlfredMeier <new@example.com>'

    it 'renders the body with a valid confirmation link' do
      token = mail.body.to_s[%r{http://test.host/changed_email_addresses/(\S+)/edit}, 1]
      expect(mail.body.to_s).to include('Diese URL ist 24 Stunden gültig.')
      expect(Login.find_by_token_for(:email_change, token)).to eq login
    end

    it 'uses the translated subject' do
      expect(mail.subject).to eq 'Änderung der E-Mail-Adresse'
    end
  end

  describe 'without name' do
    let(:login) { create(:login, email_address: 'alfred@example.com', name: '') }
    let(:mail) { described_class.with(login:).verify }

    it 'uses plain email address' do
      expect(mail.header[:to].to_s).to eq 'alfred@example.com'
    end
  end
end
