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
  end
end
