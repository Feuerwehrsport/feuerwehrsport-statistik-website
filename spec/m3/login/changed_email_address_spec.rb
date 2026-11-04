# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::ChangedEmailAddress do
  let!(:login) do
    create(:m3_login).tap do |l|
      l.update!(new_email_address: 'new@example.com')
    end
  end

  it 'uses changed_email_address_token as param column' do
    expect(described_class.param_column_name).to eq :changed_email_address_token
  end

  it 'finds only logins with recent email address changes' do
    other = create(:m3_login, email_address: 'other@example.com')
    old = create(:m3_login, email_address: 'old@example.com')
    old.update!(new_email_address: 'old-new@example.com')
    old.update_columns(changed_email_address_requested_at: 2.days.ago)

    expect(described_class.all.map(&:id)).to eq [login.id]
    expect(described_class.where(id: other.id)).to be_empty
  end

  describe '#change_email_address=' do
    let(:changed) { described_class.find(login.id) }

    it 'switches email address when confirmed' do
      changed.change_email_address = '1'
      changed.save!
      login.reload
      expect(login.email_address).to eq 'new@example.com'
      expect(login.changed_email_address).to be_nil
    end

    it 'does nothing without confirmation' do
      changed.change_email_address = '0'
      expect(changed.email_address).to eq 'my_account1994@gmail.com'
      expect(changed.changed_email_address).to eq 'new@example.com'
    end
  end
end
