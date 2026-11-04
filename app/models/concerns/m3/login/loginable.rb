# frozen_string_literal: true

module M3::Login::Loginable
  extend ActiveSupport::Concern

  included do
    belongs_to :login, class_name: 'M3::Login::Base', dependent: :destroy
    accepts_nested_attributes_for :login
    validates :login, presence: true, if: :login_required?
  end

  class_methods do
    def for_login(login)
      login.present? ? where(login:).first : nil
    end
  end

  def login
    super || build_login
  end

  protected

  def login_required?
    true
  end
end
