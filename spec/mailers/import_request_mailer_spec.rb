# frozen_string_literal: true

require 'rails_helper'

describe ImportRequestMailer do
  describe '#new_request' do
    let(:website) { admin_user.login.website }
    let(:import_request) { create(:import_request, admin_user: create(:admin_user)) }
    let(:admin_user) { create(:admin_user, :sub_admin) }
    let(:mail) { described_class.configure(website, nil, :new_request, import_request) }

    it 'renders the header information and render body' do
      expect(mail.subject).to eq 'Import-Anfrage bei Feuerwehrsport-Statistik'
      expect(mail.to).to eq ['sub_admin@example.com']
      expect(mail.from).to eq ['info@kranbauer.de']

      expect_with_mailer_signature(
        "Es wurde ein neuer Import gemeldet:\n" \
        "\n" \
        "Absender: admin user\n" \
        "Beschreibung:\n" \
        "Am 21.09.2013 fand das Finale des Deutschland-Cups in Charlottenthal statt.\n" \
        "\n" \
        "http://www.kranbauer.de/backend/import_requests\n",
      )
    end
  end
end
