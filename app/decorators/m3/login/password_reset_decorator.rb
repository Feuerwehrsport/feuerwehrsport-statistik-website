# frozen_string_literal: true

class M3::Login::PasswordResetDecorator < ApplicationDecorator
  def to_s
    login.name.presence || login.email_address
  end
end
