# frozen_string_literal: true

class M3::Login::ChangedEmailAddress < M3::Login::Base
  default_scope do
    where.not(changed_email_address: nil).where(arel_table[:changed_email_address_requested_at].gt(1.day.ago))
  end

  def self.param_column_name
    :changed_email_address_token
  end

  def change_email_address=(value)
    return if value != '1'

    self.email_address = changed_email_address
    self.changed_email_address = nil
  end
end
