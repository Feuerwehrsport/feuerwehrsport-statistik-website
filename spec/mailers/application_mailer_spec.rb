# frozen_string_literal: true

require 'rails_helper'

describe ApplicationMailer do
  include ActiveJob::TestHelper

  describe 'delivery job' do
    let(:login) { create(:m3_login) }

    it 'uses own delivery job for deliver_later' do
      expect(described_class.delivery_job).to eq ApplicationMailer::DeliveryJob
      expect(LoginMailer.delivery_job).to eq ApplicationMailer::DeliveryJob

      expect { LoginMailer.with(login:).verify.deliver_later }.to have_enqueued_job(ApplicationMailer::DeliveryJob)
    end

    [
      Net::SMTPServerBusy.new('busy'),
      Timeout::Error.new,
      OpenSSL::SSL::SSLError.new,
      Errno::ECONNREFUSED.new,
      IOError.new,
      SocketError.new,
    ].each do |error|
      it "retries delivery on #{error.class}" do
        allow_any_instance_of(Mail::Message).to receive(:deliver).and_raise(error)

        expect do
          ApplicationMailer::DeliveryJob.perform_now('LoginMailer', 'verify', 'deliver_now',
                                                     params: { login: }, args: [])
        end.to have_enqueued_job(ApplicationMailer::DeliveryJob)
      end
    end

    it 'gives up after 10 attempts' do
      attempts = 0
      allow_any_instance_of(Mail::Message).to receive(:deliver) do
        attempts += 1
        raise SocketError
      end

      expect do
        perform_enqueued_jobs { LoginMailer.with(login:).verify.deliver_later }
      end.to(raise_error { |error| expect(error.try(:error) || error).to be_a(SocketError) })
      expect(attempts).to eq 10
    end

    it 'does not retry on other errors' do
      allow_any_instance_of(Mail::Message).to receive(:deliver).and_raise(ArgumentError)

      expect do
        expect do
          ApplicationMailer::DeliveryJob.perform_now('LoginMailer', 'verify', 'deliver_now',
                                                     params: { login: }, args: [])
        end.to raise_error(ArgumentError)
      end.not_to have_enqueued_job(ApplicationMailer::DeliveryJob)
    end
  end
end
