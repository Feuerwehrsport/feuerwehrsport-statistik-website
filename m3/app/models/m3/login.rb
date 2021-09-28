# frozen_string_literal: true

module M3::Login
  def self.table_name_prefix
    'm3_login_'
  end

  def self.find(*args)
    M3::Login::Base.find(*args)
  end
end
