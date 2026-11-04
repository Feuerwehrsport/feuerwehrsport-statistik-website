# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::Base do
  let(:login) { create(:m3_login) }

  describe 'validations' do
    it 'normalizes email address' do
      record = described_class.new(email_address: '  Foo@Example.COM ', password: 'Secret123')
      expect(record).to be_valid
      expect(record.email_address).to eq 'foo@example.com'
    end

    it 'requires a valid email address' do
      record = described_class.new(email_address: 'no-mail', password: 'Secret123')
      expect(record).not_to be_valid
      expect(record.errors).to include(:email_address)
    end

    it 'requires a password for new records' do
      record = described_class.new(email_address: 'foo@example.com')
      expect(record).not_to be_valid
      expect(record.errors).to include(:password)
    end

    it 'assigns tokens on create' do
      record = described_class.create!(email_address: 'foo@example.com', password: 'Secret123')
      expect(record.verify_token).to be_present
      expect(record.password_reset_token).to be_present
      expect(record.changed_email_address_token).to be_present
    end
  end

  describe 'password' do
    it 'authenticates with correct password only' do
      expect(login.authenticate('Secret123')).to eq login
      expect(login.authenticate('wrong')).to be false
    end
  end

  describe 'verification' do
    let(:login) { create(:m3_login, :not_verified) }

    it 'is not verified' do
      expect(login).not_to be_verified
      expect(login.verified).to be false
      expect(described_class.verified).not_to include(login)
    end

    it 'can be verified' do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 10)) do
        login.verify!
        expect(login.reload.verified_at).to eq Time.zone.local(2020, 1, 1, 10)
      end
      expect(described_class.verified).to include(login)
    end

    it 'does not change verified_at when already verified' do
      login.update!(verified_at: Time.zone.local(2019, 1, 1))
      login.verify!
      expect(login.reload.verified_at).to eq Time.zone.local(2019, 1, 1)
    end

    it 'can be set with verified=' do
      login.verified = '1'
      expect(login).to be_verified
      login.verified = '0'
      expect(login).not_to be_verified
      login.verified = true
      expect(login).to be_verified
    end
  end

  describe '#expired?' do
    it 'returns false without expired_at' do
      expect(login).not_to be_expired
    end

    it 'returns true with expired_at in past' do
      expect(build(:m3_login, :expired)).to be_expired
    end

    it 'returns false with expired_at in future' do
      expect(build(:m3_login, expired_at: 1.hour.from_now)).not_to be_expired
    end
  end

  describe '.valid_password_reset' do
    it 'includes only recent requests' do
      recent = create(:m3_login, email_address: 'recent@example.com', password_reset_requested_at: 1.hour.ago)
      create(:m3_login, email_address: 'old@example.com', password_reset_requested_at: 2.days.ago)
      create(:m3_login, email_address: 'never@example.com')
      expect(described_class.valid_password_reset).to contain_exactly(recent)
    end
  end

  describe '#new_email_address=' do
    it 'stores changed email address and generates a token' do
      old_token = login.changed_email_address_token
      Timecop.freeze(Time.zone.local(2020, 1, 1, 10)) do
        login.new_email_address = 'new@example.com'
        expect(login.changed_email_address_requested_at).to eq Time.zone.local(2020, 1, 1, 10)
      end
      expect(login.changed_email_address).to eq 'new@example.com'
      expect(login.new_email_address).to eq 'new@example.com'
      expect(login.changed_email_address_token).not_to eq old_token
      expect(login.email_address).to eq 'my_account1994@gmail.com'
    end

    it 'ignores same or blank email address' do
      login.new_email_address = login.email_address
      login.new_email_address = ''
      expect(login.changed_email_address).to be_nil
      expect(login.new_email_address).to eq login.email_address
    end

    it 'validates new email address' do
      login.new_email_address = 'invalid'
      expect(login).not_to be_valid
      expect(login.errors).to include(:new_email_address)
    end
  end

  describe 'M3::Login.find' do
    it 'finds base login' do
      expect(M3::Login.find(login.id)).to eq login
    end
  end
end
