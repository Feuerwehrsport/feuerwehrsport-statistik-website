# frozen_string_literal: true

class AdminUser < ApplicationRecord
  include M3::Login::Loginable
  delegate :name, :email_address, to: :login, allow_nil: true

  ROLES = %i[
    user
    sub_admin
    admin
  ].freeze

  scope :admins, -> { where(role: %i[sub_admin admin]) }
  scope :change_request_notification_receiver, -> { admins }
  scope :filter_collection, -> { joins(:login).order(Arel.sql('admin_users.role, m3_logins.name')) }
  scope :where_name_like, ->(value) { joins(:login).where('m3_logins.name ILIKE ?', "%#{value}%") }

  validates :role, inclusion: { in: ROLES }
  schema_validations

  def role
    super.try(:to_sym)
  end
end
