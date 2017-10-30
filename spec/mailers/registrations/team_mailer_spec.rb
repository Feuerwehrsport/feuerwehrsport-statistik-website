require 'rails_helper'

describe Registrations::TeamMailer do
  pending '#state_changed' do
    let(:website) { create(:m3_website) }
    let(:order) { create(:order) }
    let(:mail) { described_class.configure(website, locale, :state_changed, order, order.state.key) }

    it 'renders the header information' do
      expect(mail.subject).to eq l('Auftrag erstellt', 'Order created')
      expect(mail.to).to eq(['my_account1994@gmail.com'])
      expect(mail.from).to eq(['info@kranbauer.de'])
    end

    it 'assigns body' do
      expected_text = l(
        'vielen Dank für Ihre Beauftragung und das entgegengebrachte Vertrauen',
        'thank you for your order.',
      )
      expect(mail.body.raw_source).to include expected_text
    end
  end
end
