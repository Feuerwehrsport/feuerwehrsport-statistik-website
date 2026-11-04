# frozen_string_literal: true

class M3::Login::ExpiredLogin < M3::Login::PasswordReset
  def persisted?
    false
  end
end
