# frozen_string_literal: true

class M3::Login::Session
  include M3::FormObject

  ID_KEY = 'm3_login_id'

  attr_accessor :email_address, :password, :session, :from_session
  attr_writer :login

  validates :email_address, presence: true
  validate :valid_login
  validate :session_is_hash

  def self.find_by_session(session)
    return unless session && session[ID_KEY]

    login = M3::Login::Base.where(
      M3::Login::Base.arel_table[:expired_at].eq(nil).or(M3::Login::Base.arel_table[:expired_at].gt(Time.current)),
    ).find_by(id: session[ID_KEY])
    new(session:, login:) if login
  end

  def login
    @login ||= M3::Login::Base.find_by(email_address: email_address.try(:downcase).try(:strip))
  end

  def persisted?
    session && self.class.find_by_session(session)
  end

  def save(validate: true)
    if !validate || valid?
      assign_session_data
      true
    else
      false
    end
  end

  def destroy
    session[ID_KEY] = nil if session
  end

  def login_expired?
    login.present? && login.expired?
  end

  def login_verified?
    login.present? && login.verified?
  end

  def assign_session_data
    session[ID_KEY] = login.id
  end

  private

  def valid_login
    if login.blank? || login.nil? || !login.authenticate(password)
      errors.add(:password, :invalid)
    elsif login_expired?
      errors.add(:password, :expired)
    elsif !login_verified?
      errors.add(:email_address, :unverified)
    end
  end

  def session_is_hash
    errors.add(:session, :invalid) unless session.respond_to?(:[]=)
  end
end
