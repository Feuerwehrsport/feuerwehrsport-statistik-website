# frozen_string_literal: true

require 'rails_helper'

describe ImportRequestMailer do
  describe '#new_request' do
    let!(:admin_user) { create(:admin_user, :sub_admin) }
    let(:import_request) { create(:import_request, admin_user: create(:admin_user)) }
    let(:mail) { described_class.with(import_request:).new_request }

    it 'renders the header information and render body' do
      expect(mail.subject).to eq 'Import-Anfrage bei Feuerwehrsport-Statistik'
      expect(mail.header[:to].to_s).to eq 'sub_admin <sub_admin@example.com>'
      expect(mail.header[:from].to_s).to eq 'Feuerwehrsport-Statistik <automailer@feuerwehrsport-statistik.de>'
      expect(mail.header[:cc].to_s).to eq ''
      expect(mail.header[:reply_to].to_s).to eq ''

      expect(mail.attachments.count).to eq 0

      expect_with_mailer_signature(
        "Es wurde ein neuer Import gemeldet:\n" \
        "\n" \
        "Absender: admin user\n" \
        "Beschreibung:\n" \
        "Am 21.09.2013 fand das Finale des Deutschland-Cups in Charlottenthal statt.\n" \
        "\n" \
        "http://test.host/backend/import_requests\n",
      )
    end

    context 'with multiple receivers' do
      before { create(:admin_user, :admin) }

      it 'sends to all admins except the sender' do
        expect(mail.to).to contain_exactly('sub_admin@example.com', 'admin@example.com')
      end
    end

    context 'when sender is the only admin' do
      let(:import_request) { create(:import_request, admin_user:) }

      it 'sends no mail' do
        pending 'Bug: ImportRequestMailer liefert anders als ChangeRequestMailer keine NullMail ohne Empfänger'
        expect(mail.message).to be_a(ActionMailer::Base::NullMail)
        expect { mail.deliver_now }.not_to raise_error
      end
    end
  end
end
