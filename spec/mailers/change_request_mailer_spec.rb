# frozen_string_literal: true
require 'rails_helper'

describe ChangeRequestMailer do
  describe '#new_notification' do
    let(:change_request) { ChangeRequest.new }
    let(:website) { admin_user.login.website }
    let(:admin_user) { create(:admin_user, :sub_admin) }
    let(:mail) { described_class.configure(website, nil, :new_notification, change_request) }

    it 'renders the header information and render body' do
      expect(mail.subject).to eq 'Fehler bei Feuerwehrsport-Statistik'
      expect(mail.to).to eq ['sub_admin@example.com']
      expect(mail.from).to eq ['info@kranbauer.de']

      expect_with_mailer_signature(
        "Es wurde ein neuer Hinweis gemeldet:\n" \
        "\n" \
        "Stichpunkt: \n" \
        "Inhalt: \n" \
        "Absender: \n" \
        "\n" \
        "http://www.kranbauer.de/backend/change_requests\n",
      )
    end
  end
end
