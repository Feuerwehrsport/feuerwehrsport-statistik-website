# frozen_string_literal: true

class M3::Login::PasswordReset
  include M3::FormObject

  attr_accessor :email_address, :website, :token

  validates :email_address, :login, :website, presence: true
  validate do
    errors.add(:email_address, :invalid) if email_address.present? && login.blank?
    if login.present? && !login.valid?
      login.errors.each do |attribute, message|
        errors[attribute].push(message)
      end
    end
  end

  delegate :password, :password=, :password_confirmation, :password_confirmation=, to: :login

  def login
    @login ||= website.logins.find_by(email_address: email_address.try(:downcase))
  end

  def login=(login)
    self.email_address = login.email_address
  end

  def persisted?
    token.present? && login.present?
  end

  def self.find(website, token)
    new(website: website, token: token,
        login: website.logins.valid_password_reset.find_by!(password_reset_token: token))
  end

  def save
    if valid?
      if token.present?
        login.expired_at = nil
        login.verified_at = Time.current if login.verified_at.blank?
      else
        login.regenerate_password_reset_token
        login.password_reset_requested_at = Time.current
      end
      login.save
    else
      false
    end
  end
end
