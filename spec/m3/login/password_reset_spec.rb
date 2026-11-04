# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::PasswordReset do
  let!(:login) { create(:m3_login, :not_verified, :expired) }

  describe 'request (without token)' do
    it 'regenerates password reset token' do
      reset = described_class.new(email_address: 'MY_ACCOUNT1994@gmail.com')
      old_token = login.password_reset_token
      Timecop.freeze(Time.zone.local(2020, 1, 1, 10)) do
        expect(reset.save).to be true
      end
      login.reload
      expect(login.password_reset_token).not_to eq old_token
      expect(login.password_reset_requested_at).to eq Time.zone.local(2020, 1, 1, 10)
      expect(login).not_to be_verified
      expect(login).to be_expired
    end

    it 'fails for unknown email address' do
      reset = described_class.new(email_address: 'unknown@example.com')
      expect(reset.save).to be false
      expect(reset.errors).to include(:email_address)
      expect(reset.errors).to include(:login)
    end

    it 'fails without email address' do
      reset = described_class.new
      expect(reset.save).to be false
      expect(reset.errors).to include(:email_address)
    end
  end

  describe '.find' do
    it 'finds valid password reset by token' do
      login.update!(password_reset_requested_at: 1.hour.ago)
      reset = described_class.find(login.password_reset_token)
      expect(reset.login).to eq login
      expect(reset.token).to eq login.password_reset_token
      expect(reset).to be_persisted
    end

    it 'raises for outdated tokens' do
      login.update!(password_reset_requested_at: 2.days.ago)
      expect { described_class.find(login.password_reset_token) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'set new password (with token)' do
    let(:reset) do
      login.update!(password_reset_requested_at: 1.hour.ago)
      described_class.find(login.password_reset_token)
    end

    it 'sets new password, verifies and unexpires login' do
      reset.password = 'NewSecret456'
      reset.password_confirmation = 'NewSecret456'
      expect(reset.save).to be true
      login.reload
      expect(login.authenticate('NewSecret456')).to eq login
      expect(login).to be_verified
      expect(login).not_to be_expired
    end

    it 'copies errors from invalid login' do
      reset.password = 'NewSecret456'
      reset.password_confirmation = 'other'
      expect(reset.save).to be false
      expect(reset.errors).to include(:password_confirmation)
    end
  end

  describe M3::Login::ExpiredLogin do
    it 'is never persisted' do
      login.update!(password_reset_requested_at: 1.hour.ago)
      expect(described_class.find(login.password_reset_token)).not_to be_persisted
    end
  end
end
