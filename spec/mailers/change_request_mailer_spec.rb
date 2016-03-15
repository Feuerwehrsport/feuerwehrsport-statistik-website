require "rails_helper"

RSpec.describe ChangeRequestMailer, type: :mailer do
  describe 'new_notification' do
    let(:change_request) { ChangeRequest.new }
    let(:mail) { described_class.new_notification(change_request) }

    it 'renders the receiver email' do
      expect(mail.to).to eq ["sub_admin@first.com", "sub_admin@second.com", "admin@first.com", "admin@second.com"]
    end

    it 'renders the sender email' do
      expect(mail.from).to eq ["automailer@feuerwehrsport-statistik.de"]
    end

    it 'renders body' do
      expect(mail.body.encoded).to include backend_change_requests_url
    end
  end
end
