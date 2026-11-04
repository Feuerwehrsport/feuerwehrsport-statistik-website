# frozen_string_literal: true

# Login data of an admin user (email address and password).
# Tokens for verification, password reset and email change are signed and not stored in the database.
class Login < ApplicationRecord
  has_secure_password reset_token: { expires_in: 1.day }
  generates_token_for(:verification) { verified_at }
  generates_token_for(:email_change, expires_in: 1.day) { [email_address, changed_email_address] }

  has_one :admin_user, dependent: nil

  normalizes :email_address, :changed_email_address, with: ->(email) { email.strip.downcase }

  validates :email_address, 'valid_email_2/email': true
  validates :changed_email_address, 'valid_email_2/email': true, allow_blank: true
  schema_validations

  scope :verified, -> { where.not(verified_at: nil) }
  scope :not_expired, -> { where(expired_at: nil).or(where(expired_at: Time.current..)) }

  def verified?
    verified_at.present?
  end

  def verify!
    update!(verified_at: Time.current) unless verified?
  end

  def expired?
    expired_at.present? && expired_at < Time.current
  end

  # used by the admin user form: a different address is only applied after confirmation by email
  def new_email_address
    changed_email_address.presence || email_address
  end

  def new_email_address=(address)
    self.changed_email_address = address if address.present? && address.strip.downcase != email_address
  end

  def confirm_email_change!
    update!(email_address: changed_email_address, changed_email_address: nil)
  end

  # sets a new password from the reset form and unlocks the login
  def reset_password(password:, password_confirmation:)
    if password.blank?
      errors.add(:password, :blank)
      return false
    end

    self.password = password
    self.password_confirmation = password_confirmation
    self.expired_at = nil
    self.verified_at ||= Time.current
    save
  end
end
