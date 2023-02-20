# frozen_string_literal: true

class M3::Login::Base < ApplicationRecord
  self.table_name = 'm3_logins'
  has_secure_password
  has_secure_token :verify_token
  has_secure_token :password_reset_token
  has_secure_token :changed_email_address_token
  belongs_to :website, class_name: 'M3::Website'
  validates :email_address, 'valid_email_2/email': true, presence: true, uniqueness: { scope: :website }
  validates :new_email_address, 'valid_email_2/email': true
  before_validation :normalize_email_address
  before_validation :assign_tokens

  scope :verified, -> { where.not(verified_at: nil) }
  scope :valid_password_reset, -> do
    where(arel_table[:password_reset_requested_at].gteq(1.day.ago)).where.not(password_reset_token: nil)
  end

  def verified?
    verified_at.present?
  end

  def verify!
    update(verified_at: Time.current) unless verified?
  end

  def verified
    verified?
  end

  def verified=(bool)
    self.verified_at = (Time.current if bool.is_a?(TrueClass) || bool.to_s == '1')
  end

  def expired?
    !expired_at.nil? && expired_at < Time.current
  end

  def new_email_address
    @new_email_address.presence || email_address
  end

  def new_email_address=(email_address)
    return unless email_address != self.email_address && email_address.present?

    @new_email_address = email_address
    self.changed_email_address = email_address
    self.changed_email_address_token = self.class.generate_unique_secure_token if changed_email_address_changed?
    self.changed_email_address_requested_at = Time.current
  end

  private

  def normalize_email_address
    self.email_address = email_address.downcase.strip if email_address.present?
  end

  def assign_tokens
    self.changed_email_address_token ||= self.class.generate_unique_secure_token
  end
end
