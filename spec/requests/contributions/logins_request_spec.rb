# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contributions::Logins' do
  def question_answer
    question = response.parsed_body.at_css('label[for=captcha_answer]').text
    a, operation, b = question.split
    a.to_i.public_send(ApiLoginChallenge::OPERATIONS.fetch(operation), b.to_i)
  end

  def login(answer:, name: 'Tester', website: '', return_to: '/contributions/people/new')
    post '/contributions/login', params: { api_user: { name:, email_address: '' }, captcha_answer: answer,
                                           website:, return_to: }
  end

  it 'redirects to the login when not logged in' do
    get '/contributions/people/new'
    expect(response).to redirect_to('/contributions/login/new?return_to=%2Fcontributions%2Fpeople%2Fnew')
  end

  it 'logs in and returns to the requested dialog' do
    get '/contributions/login/new'
    expect(response.body).to include('turbo-frame id="contribution"')

    expect { login(answer: question_answer) }.to change(ApiUser, :count).by(1)
    expect(response).to redirect_to('/contributions/people/new')

    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Person hinzufügen')
  end

  it 'only returns to contribution paths' do
    get '/contributions/login/new'
    login(answer: question_answer, return_to: '//evil.example/contributions/')
    expect(response).to redirect_to('/')
  end

  it 'shows the form again with a new question for a wrong answer' do
    get '/contributions/login/new'
    expect { login(answer: question_answer + 1) }.not_to change(ApiUser, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Die Antwort ist nicht korrekt.')
    expect(response.parsed_body.at_css('label[for=captcha_answer]').text).to match(/\A\d+ (plus|minus|mal) \d+\z/)
  end

  it 'requires a name or an email address' do
    get '/contributions/login/new'
    expect { login(answer: question_answer, name: '') }.not_to change(ApiUser, :count)
    expect(response.body).to include('Bitte geben Sie einen Namen oder eine E-Mail-Adresse an.')
  end

  it 'rejects a filled honeypot field' do
    get '/contributions/login/new'
    expect { login(answer: question_answer, website: 'spam') }.not_to change(ApiUser, :count)
    expect(response.body).to include('Die Anmeldung ist fehlgeschlagen.')
  end
end
