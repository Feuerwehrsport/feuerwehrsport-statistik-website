# frozen_string_literal: true

module MailerSupport
  def deliver_later(mailer, method, *args)
    M3::MailerConfiguration.enqueue(m3_website, params[:locale], mailer, method, args)
    view_context # call view_context to fix wrong template handling draper
  end

  def deliver_now(mailer, method, *args)
    M3::MailerConfiguration.perform_now(m3_website, params[:locale], mailer, method, args)
    view_context # call view_context to fix wrong template handling draper
  end
end
