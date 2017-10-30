class AdminUser < ActiveRecord::Base
  include M3::Login::Loginable
  delegate :name, :email_address, to: :login, allow_nil: true

  ROLES = %i[
    user
    sub_admin
    admin
  ].freeze

  has_many :news_articles, dependent: :restrict_with_exception

  scope :change_request_notification_receiver, -> { where(role: %i[sub_admin admin]) }
  scope :filter_collection, -> { joins(:login).order('admin_users.role, m3_logins.name') }

  validates :role, inclusion: { in: ROLES }

  def role
    super.try(:to_sym)
  end
end
