# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :current_login
  end

  protected

  def current_session
    @current_session ||= M3::Login::Session.find_by(session:)
  end

  def current_login
    @current_login ||= current_session.try(:login)
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_login)
  end
end
