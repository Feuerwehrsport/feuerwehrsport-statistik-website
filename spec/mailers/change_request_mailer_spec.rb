# frozen_string_literal: true

require 'rails_helper'

describe ChangeRequestMailer do
  describe '#new_notification' do
    let!(:admin_user) { create(:admin_user, :sub_admin) }
    let(:change_request) { ChangeRequest.new }
    let(:mail) { described_class.with(change_request: change_request).new_notification }

    it 'renders the header information and render body' do
      expect(mail.subject).to eq 'Fehler bei Feuerwehrsport-Statistik'
      expect(mail.header[:to].to_s).to eq 'sub_admin <sub_admin@example.com>'
      expect(mail.header[:from].to_s).to eq 'Feuerwehrsport-Statistik <automailer@feuerwehrsport-statistik.de>'
      expect(mail.header[:cc].to_s).to eq ''
      expect(mail.header[:reply_to].to_s).to eq ''

      expect(mail.attachments).to have(0).attachments

      expect_with_mailer_signature(
        "Es wurde ein neuer Hinweis gemeldet:\n" \
        "\n" \
        "Stichpunkt: \n" \
        "Inhalt: \n" \
        "Absender: \n" \
        "\n" \
        "http://test.host/backend/change_requests\n",
      )
    end
  end
end
