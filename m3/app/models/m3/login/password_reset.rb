# frozen_string_literal: true

class M3::Login::PasswordReset
  include M3::FormObject

  attr_accessor :email_address, :token

  validates :email_address, :login, presence: true
  validate do
    errors.add(:email_address, :invalid) if email_address.present? && login.blank?
    if login.present? && login.invalid?
      login.errors.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end

  delegate :password, :password=, :password_confirmation, :password_confirmation=, to: :login

  def login
    @login ||= M3::Login::Base.find_by(email_address: email_address.try(:downcase))
  end

  def login=(login)
    self.email_address = login.email_address
  end

  def persisted?
    token.present? && login.present?
  end

  def self.find(token)
    new(token:, login: M3::Login::Base.valid_password_reset.find_by!(password_reset_token: token))
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
