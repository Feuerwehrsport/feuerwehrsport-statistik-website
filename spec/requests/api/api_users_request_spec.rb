# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::ApiUsers' do
  def fetch_challenge
    post '/api/api_users/challenge'
    question = json_body[:question]
    a, operation, b = question.split
    a.to_i.public_send(ApiLoginChallenge::OPERATIONS.fetch(operation), b.to_i)
  end

  def login(answer:, api_user: { name: 'hans', email_address: 'email-address@foo.de' }, website: '')
    post '/api/api_users', params: { api_user:, captcha_answer: answer, website: }
  end

  describe 'POST status' do
    context 'when session is not set' do
      it 'returns login false' do
        post '/api/api_users/status'
        expect_api_not_login_response
      end
    end

    context 'when session user id is set', login: :api do
      it 'returns login true' do
        post '/api/api_users/status'
        expect_api_login_response
      end
    end
  end

  describe 'POST challenge' do
    it 'returns an arithmetic question without the answer' do
      post '/api/api_users/challenge'
      expect(json_body[:question]).to match(/\A\d+ (plus|minus|mal) \d+\z/)
      expect(json_body.keys).to contain_exactly(:success, :login, :question)
    end
  end

  describe 'POST create' do
    let(:login_user) { ApiUser.last }

    it 'creates new user and sign in with correct answer' do
      answer = fetch_challenge
      expect { login(answer:) }.to change(ApiUser, :count).by(1)
      expect_api_login_response
    end

    it 'accepts only an email address' do
      answer = fetch_challenge
      expect { login(answer:, api_user: { name: '', email_address: 'email-address@foo.de' }) }
        .to change(ApiUser, :count).by(1)
    end

    it 'fails without name and email address' do
      answer = fetch_challenge
      expect { login(answer:, api_user: { name: ' ', email_address: '' }) }.not_to change(ApiUser, :count)
      expect_api_not_login_response(success: false,
                                    message: 'Bitte geben Sie einen Namen oder eine E-Mail-Adresse an.')
    end

    it 'fails with a wrong answer' do
      answer = fetch_challenge
      expect { login(answer: answer + 1) }.not_to change(ApiUser, :count)
      expect_api_not_login_response(success: false, message: 'Die Antwort ist nicht korrekt.')
    end

    it 'fails without challenge' do
      expect { login(answer: 4) }.not_to change(ApiUser, :count)
      expect_api_not_login_response(success: false,
                                    message: 'Die Rechenaufgabe ist abgelaufen. Bitte versuchen Sie es erneut.')
    end

    it 'allows a challenge only once' do
      answer = fetch_challenge
      login(answer: answer + 1)
      expect { login(answer:) }.not_to change(ApiUser, :count)
      expect_api_not_login_response(success: false,
                                    message: 'Die Rechenaufgabe ist abgelaufen. Bitte versuchen Sie es erneut.')
    end

    it 'fails when the honeypot field is filled' do
      answer = fetch_challenge
      expect { login(answer:, website: 'http://spam.example') }.not_to change(ApiUser, :count)
      expect_api_not_login_response(success: false, message: 'Die Anmeldung ist fehlgeschlagen.')
    end

    it 'fails when answered too fast' do
      allow(Rails.configuration.x).to receive(:api_login_min_seconds).and_return(3)
      answer = fetch_challenge
      expect { login(answer:) }.not_to change(ApiUser, :count)
      expect_api_not_login_response(success: false, message: 'Das ging zu schnell. Bitte versuchen Sie es erneut.')
    end

    it 'fails when the challenge is expired' do
      answer = fetch_challenge
      travel(31.minutes) do
        expect { login(answer:) }.not_to change(ApiUser, :count)
      end
    end

    it 'limits the number of attempts' do
      10.times { post '/api/api_users/challenge' }
      post '/api/api_users/challenge'
      expect(response).to have_http_status(:too_many_requests)
      expect(json_body[:message]).to eq 'Zu viele Anmeldeversuche. Bitte versuchen Sie es später erneut.'
    end

    context 'when email_address is not valid' do
      it 'fails to create new user' do
        answer = fetch_challenge
        login(answer:, api_user: { name: 'hans', email_address: 'not-valid' })
        expect_api_not_login_response success: false, message: 'E-Mail-Adresse ist nicht gültig'
      end
    end
  end

  describe 'POST logout' do
    before do
      answer = fetch_challenge
      login(answer:)
    end

    it 'log user out' do
      post '/api/api_users/logout'
      expect_api_not_login_response
    end
  end
end
