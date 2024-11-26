# frozen_string_literal: true

module M3::Login
  def self.table_name_prefix
    'm3_login_'
  end

  def self.find(*)
    M3::Login::Base.find(*)
  end
end
