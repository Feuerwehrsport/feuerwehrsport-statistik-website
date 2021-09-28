# frozen_string_literal: true

M3::MailerConfiguration = Struct.new(:website, :locale, :mailer, :method_name, :arguments) do
  self::TIMEOUT = 60
  include M3::Delayable

  def self.enqueue(website, locale, mailer, method_name, *arguments)
    options = {}
    options[:queue] = mailer.delayed_queue if mailer.respond_to?(:delayed_queue) && mailer.delayed_queue.present?
    enqueue_with_options(options, website, locale, mailer, method_name, *arguments)
  end

  def perform
    rollback = false
    ActiveRecord::Base.transaction do
      Timeout.timeout(M3::MailerConfiguration::TIMEOUT) { deliver }
    rescue Timeout::Error, Net::SMTPServerBusy, Errno::ECONNABORTED, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError
      Rails.logger.warn('Mailer: Network error - will retry')
      rollback = true
      raise ActiveRecord::Rollback
    rescue Net::SMTPAuthenticationError, SocketError => e
      if e.message.starts_with?('421 4.3.2 Service not active') ||
         e.message.starts_with?('454 4.7.0 Temporary authentication failure') ||
         e.message.starts_with?('451 4.7.0 Temporary server error') ||
         e.message.starts_with?('451 Internal server error') ||
         e.message.starts_with?('getaddrinfo: Temporary failure in name resolution')

        Rails.logger.warn("Mailer: SMTP error - #{e.message} - will retry")

        rollback = true
        raise ActiveRecord::Rollback
      else
        raise e
      end
    end

    return unless rollback

    M3::MailerConfiguration.enqueue_with_options({ run_at: 30.minutes.from_now },
                                                 website, locale, mailer, method_name, arguments)
  end

  protected

  def deliver
    mail = mailer.configure(website, locale, method_name, *arguments)
    mail_body = mail.to_s # to generate headers in mail object
    mail.deliver
  rescue Net::SMTPFatalError => e
    handle_delivery_error(e, mail, mail_body)
  end

  def handle_delivery_error(error, mail, mail_body)
    raise error if mailer == M3::FailureMailer
    raise error unless error.message == "550-Requested action not taken: mailbox unavailable\n"

    M3::MailerConfiguration.enqueue(website, locale, M3::FailureMailer, :delivery_failed,
                                    [mail.from, mail.to, mail.reply_to, mail.subject, mail.date, mail_body])
  end
end
