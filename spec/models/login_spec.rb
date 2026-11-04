# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Login do
  let!(:login) { create(:login) }

  it 'normalizes and validates email addresses' do
    login = described_class.new(email_address: ' Alfred@Example.COM ', password: 'secret')
    expect(login.email_address).to eq 'alfred@example.com'
    expect(described_class.new(email_address: 'foo', password: 'secret')).not_to be_valid
  end

  it 'authenticates by email address and password' do
    expect(described_class.authenticate_by(email_address: 'MY_ACCOUNT1994@gmail.com', password: 'Secret123'))
      .to eq login
    expect(described_class.authenticate_by(email_address: login.email_address, password: 'wrong')).to be_nil
  end

  describe 'verification' do
    let(:login) { create(:login, :not_verified) }

    it 'verifies with a token that is only valid once' do
      token = login.generate_token_for(:verification)
      expect(described_class.find_by_token_for(:verification, token)).to eq login
      login.verify!
      expect(login).to be_verified
      expect(described_class.find_by_token_for(:verification, token)).to be_nil
    end
  end

  describe 'password reset' do
    it 'resets password with a token valid for one day and only once' do
      token = login.password_reset_token
      expect(described_class.find_by_password_reset_token(token)).to eq login

      expect(login.reset_password(password: 'NewSecret1', password_confirmation: 'NewSecret1')).to be true
      expect(login.authenticate('NewSecret1')).to be_truthy
      expect(described_class.find_by_password_reset_token(token)).to be_nil
    end

    it 'expires the token after one day' do
      token = login.password_reset_token
      travel 25.hours
      expect(described_class.find_by_password_reset_token(token)).to be_nil
    end

    it 'unexpires and verifies the login' do
      login.update!(expired_at: 1.day.ago, verified_at: nil)
      login.reset_password(password: 'NewSecret1', password_confirmation: 'NewSecret1')
      expect(login.reload).not_to be_expired
      expect(login).to be_verified
    end

    it 'rejects blank and not confirmed passwords' do
      expect(login.reset_password(password: '', password_confirmation: '')).to be false
      expect(login.errors).to include(:password)
      expect(login.reset_password(password: 'NewSecret1', password_confirmation: 'other')).to be false
      expect(login.errors).to include(:password_confirmation)
    end
  end

  describe 'email change' do
    it 'stores the new address until it is confirmed' do
      login.update!(new_email_address: 'New@Example.com')
      expect(login.email_address).to eq 'my_account1994@gmail.com'
      expect(login.changed_email_address).to eq 'new@example.com'
      expect(login.new_email_address).to eq 'new@example.com'

      token = login.generate_token_for(:email_change)
      expect(described_class.find_by_token_for(:email_change, token)).to eq login

      login.confirm_email_change!
      expect(login.reload.email_address).to eq 'new@example.com'
      expect(login.changed_email_address).to be_nil
      expect(described_class.find_by_token_for(:email_change, token)).to be_nil
    end

    it 'ignores the unchanged address' do
      login.new_email_address = login.email_address.upcase
      expect(login.changed_email_address).to be_nil
    end
  end

  describe 'scopes and states' do
    it 'knows expired and verified logins' do
      expect(build(:login, :expired)).to be_expired
      expect(build(:login, expired_at: 1.hour.from_now)).not_to be_expired
      expired = create(:login, :expired, email_address: 'expired@example.com')
      unverified = create(:login, :not_verified, email_address: 'new@example.com')
      expect(described_class.not_expired).to include(login, unverified)
      expect(described_class.not_expired).not_to include(expired)
      expect(described_class.verified).not_to include(unverified)
    end
  end
end
