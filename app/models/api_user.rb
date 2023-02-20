# frozen_string_literal: true

class ApiUser < ApplicationRecord
  has_many :change_requests, dependent: :nullify
  has_many :change_logs, dependent: :nullify

  scope :old_entries, -> { where(arel_table[:created_at].lt(1.month.ago)) }

  validates :email_address, 'valid_email_2/email': true, allow_blank: true
  validates :name, presence: true
  after_create :remove_old_entries

  def user_agent=(user_agent)
    self.user_agent_meta = user_agent.truncate(10)
    self.user_agent_hash = Digest::SHA256.hexdigest(user_agent)
  end

  def ip_address=(ip_address)
    self.ip_address_hash = Digest::SHA256.hexdigest(ip_address)
  end

  def request_headers=(request_headers)
    self.ip_address = request_headers['X-Forwarded-For'] || request_headers['REMOTE_ADDR']
    self.user_agent = request_headers['HTTP_USER_AGENT']
  end

  def role
    :api_user
  end

  def named_email_address
    return nil if email_address.blank?

    address = Mail::Address.new email_address
    address.display_name = name
    address.format
  end

  private

  def remove_old_entries
    self.class.old_entries.destroy_all
  end
end
