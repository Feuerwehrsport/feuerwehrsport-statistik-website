require 'rails_helper'

describe ImportRequestMailer do
  describe '#new_request' do
    let(:website) { admin_user.login.website }
    let(:import_request) { create(:import_request, admin_user: create(:admin_user)) }
    let(:admin_user) { create(:admin_user, :sub_admin) }
    let(:mail) { described_class.configure(website, nil, :new_request, import_request) }

    it 'renders the header information' do
      expect(mail.subject).to eq 'Import-Anfrage bei Feuerwehrsport-Statistik'
      expect(mail.to).to eq ['admin_user@example.com']
      expect(mail.from).to eq ['info@kranbauer.de']
    end

    it 'assigns body' do
      expect(mail.body.raw_source).to include(
        "Es wurde ein neuer Import gemeldet:\n" \
        "\n" \
        "Absender: admin user\n" \
        "Beschreibung:\n" \
        "Am 21.09.2013 fand das Finale des Deutschland-Cups in Charlottenthal statt.\n" \
        "\n" \
        "http://www.kranbauer.de/backend/import_requests\n" \
        "\n" \
        "---------------------------------------------------------\n",
      )
    end
  end
end
