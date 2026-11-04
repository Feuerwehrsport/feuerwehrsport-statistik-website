# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::Session do
  let!(:login) { create(:m3_login) }
  let(:session_hash) { {} }
  let(:session) do
    described_class.new(email_address: ' My_Account1994@gmail.com ', password: 'Secret123', session: session_hash)
  end

  describe '#save' do
    it 'stores login id in session' do
      expect(session.save).to be true
      expect(session_hash).to eq(described_class::ID_KEY => login.id)
      expect(session).to be_persisted
    end

    it 'fails with wrong password' do
      session.password = 'wrong'
      expect(session.save).to be false
      expect(session.errors).to include(:password)
      expect(session_hash).to be_empty
    end

    it 'fails with unknown email address' do
      session.email_address = 'unknown@example.com'
      expect(session.save).to be false
      expect(session.errors).to include(:password)
    end

    it 'fails without email address' do
      session.email_address = ''
      expect(session.save).to be false
      expect(session.errors).to include(:email_address)
    end

    it 'fails for expired login' do
      login.update!(expired_at: 1.minute.ago)
      expect(session.save).to be false
      expect(session.errors.details[:password]).to include(error: :expired)
      expect(session).to be_login_expired
    end

    it 'fails for unverified login' do
      login.update!(verified_at: nil)
      expect(session.save).to be false
      expect(session.errors.details[:email_address]).to include(error: :unverified)
      expect(session).not_to be_login_verified
    end

    it 'fails without session hash' do
      session.session = nil
      expect(session.save).to be false
      expect(session.errors).to include(:session)
    end

    it 'can skip validation' do
      session.password = 'wrong'
      expect(session.save(validate: false)).to be true
      expect(session_hash[described_class::ID_KEY]).to eq login.id
    end
  end

  describe '.find_by' do
    it 'returns nil without session data' do
      expect(described_class.find_by(session: nil)).to be_nil
      expect(described_class.find_by(session: {})).to be_nil
    end

    it 'returns session for valid login' do
      found = described_class.find_by(session: { described_class::ID_KEY => login.id })
      expect(found.login).to eq login
    end

    it 'returns nil for expired login' do
      login.update!(expired_at: 1.minute.ago)
      expect(described_class.find_by(session: { described_class::ID_KEY => login.id })).to be_nil
    end

    it 'returns session for login expiring in future' do
      login.update!(expired_at: 1.day.from_now)
      expect(described_class.find_by(session: { described_class::ID_KEY => login.id })).to be_present
    end
  end

  describe '#destroy' do
    it 'removes login id from session' do
      session.save
      session.destroy
      expect(session_hash[described_class::ID_KEY]).to be_nil
      expect(session).not_to be_persisted
    end
  end
end
