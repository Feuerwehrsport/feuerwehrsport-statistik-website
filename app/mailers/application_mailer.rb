# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  helper ApplicationHelper

  protected

  def default_url_options
    Rails.application.config.default_url_options
  end

  def email_address_format(email_address, name = '')
    address = Mail::Address.new(email_address)
    display_name = name.to_s.dup.presence&.delete("\r\n")&.strip
    address.display_name = display_name if display_name
    address.format
  end
end
