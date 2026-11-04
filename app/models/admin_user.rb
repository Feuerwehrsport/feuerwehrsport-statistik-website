# frozen_string_literal: true

class AdminUser < ApplicationRecord
  belongs_to :login, dependent: :destroy
  accepts_nested_attributes_for :login
  validates :login, presence: true

  delegate :name, :email_address, to: :login, allow_nil: true

  ROLES = %i[
    user
    sub_admin_with_series
    sub_admin
    admin
  ].freeze

  scope :admins, -> { where(role: %i[sub_admin_with_series sub_admin admin]) }
  scope :change_request_notification_receiver, -> { admins }
  scope :filter_collection, -> { joins(:login).order(Arel.sql('admin_users.role, logins.name')) }
  scope :where_name_like, ->(value) { joins(:login).where('logins.name ILIKE ?', "%#{value}%") }

  validates :role, inclusion: { in: ROLES }
  schema_validations

  def self.for_login(login)
    login.present? ? find_by(login:) : nil
  end

  def login
    super || build_login
  end

  def role
    super.try(:to_sym)
  end
end
