# frozen_string_literal: true

require 'rails_helper'

describe ChangeRequestMailer do
  describe '#new_notification' do
    let!(:admin_user) { create(:admin_user, :sub_admin) }
    let(:change_request) { ChangeRequest.new }
    let(:mail) { described_class.with(change_request:).new_notification }

    it 'renders the header information and render body' do
      expect(mail.subject).to eq 'Fehler bei Feuerwehrsport-Statistik'
      expect(mail.header[:to].to_s).to eq 'sub_admin <sub_admin@example.com>'
      expect(mail.header[:from].to_s).to eq 'Feuerwehrsport-Statistik <automailer@feuerwehrsport-statistik.de>'
      expect(mail.header[:cc].to_s).to eq ''
      expect(mail.header[:reply_to].to_s).to eq ''

      expect(mail.attachments.count).to eq 0

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

    context 'with content and api user' do
      let(:change_request) do
        ChangeRequest.create!(content: { key: 'person-merge', data: { 'id' => 3 } }, user: create(:api_user))
      end

      it 'renders content and sender' do
        expect_with_mailer_signature(
          "Es wurde ein neuer Hinweis gemeldet:\n" \
          "\n" \
          "Stichpunkt: person-merge\n" \
          "Inhalt: {id: 3}\n" \
          "Absender: Api User\n" \
          "\n" \
          "http://test.host/backend/change_requests\n",
        )
      end
    end

    context 'with multiple receivers' do
      let!(:admin) { create(:admin_user, :admin) }

      before { create(:admin_user, :user) }

      it 'sends to all admins except the sender' do
        expect(mail.to).to contain_exactly('sub_admin@example.com', 'admin@example.com')

        change_request.user = admin
        expect(described_class.with(change_request:).new_notification.to).to eq ['sub_admin@example.com']
      end
    end

    context 'with sub_admin_with_series' do
      before do
        create(:admin_user, role: :sub_admin_with_series,
                            login: create(:login, email_address: 'series@example.com', name: 'series'))
      end

      it 'sends also to sub admins with series' do
        expect(mail.to).to contain_exactly('sub_admin@example.com', 'series@example.com')
      end
    end

    context 'without receivers' do
      let(:change_request) { ChangeRequest.new(user: admin_user) }

      it 'sends no mail' do
        expect(mail.message).to be_a(ActionMailer::Base::NullMail)
        expect { mail.deliver_now }.not_to(change { ActionMailer::Base.deliveries.count })
      end
    end
  end
end
