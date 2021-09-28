# frozen_string_literal: true

class M3::Login::BaseDecorator < ApplicationDecorator
  localizes :verified_at, :expired_at

  def to_s
    name.presence || email_address
  end

  def old_email_address
    email_address
  end
end
