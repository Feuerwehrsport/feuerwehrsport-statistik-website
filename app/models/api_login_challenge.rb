# frozen_string_literal: true

# Server-side protection for the anonymous login (ApiUser): an arithmetic question whose answer is kept in a
# server-side store (the session only holds a random id), usable once, with a minimum time to answer.
class ApiLoginChallenge
  SESSION_KEY = :api_login_challenge
  EXPIRES_IN = 30.minutes
  OPERATIONS = { 'plus' => :+, 'minus' => :-, 'mal' => :* }.freeze

  def self.store
    Rails.configuration.x.api_login_store
  end

  def self.min_seconds
    Rails.configuration.x.api_login_min_seconds
  end

  # creates a new question, returns its text
  def self.issue(session)
    question, answer = generate
    id = SecureRandom.urlsafe_base64(24)
    store.write("api_login_challenge/#{id}", { answer:, issued_at: Time.current.to_f }, expires_in: EXPIRES_IN)
    session[SESSION_KEY] = id
    question
  end

  HONEYPOT_PARAM = :website

  # checks honeypot and answer of a login request, returns nil or an error message
  def self.verify_request(session, params)
    return 'Die Anmeldung ist fehlgeschlagen.' if params[HONEYPOT_PARAM].present?

    verify(session, params[:captcha_answer])
  end

  # returns nil when the answer is correct, otherwise an error message; the challenge can only be used once
  def self.verify(session, given_answer)
    id = session.delete(SESSION_KEY)
    key = "api_login_challenge/#{id}"
    challenge = store.read(key) if id.present?
    store.delete(key) if challenge

    return 'Die Rechenaufgabe ist abgelaufen. Bitte versuchen Sie es erneut.' if challenge.nil?
    if Time.current.to_f - challenge[:issued_at] < min_seconds
      return 'Das ging zu schnell. Bitte versuchen Sie es erneut.'
    end
    return 'Die Antwort ist nicht korrekt.' unless given_answer.to_s.strip == challenge[:answer].to_s

    nil
  end

  def self.generate
    loop do
      name, operator = OPERATIONS.to_a.sample
      a = SecureRandom.random_number(11)
      b = SecureRandom.random_number(10)
      answer = a.public_send(operator, b)
      return ["#{a} #{name} #{b}", answer] if answer.between?(0, 50)
    end
  end
end
