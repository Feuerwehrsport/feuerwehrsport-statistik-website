# frozen_string_literal: true

class M3::FailureMailer < ApplicationMailer
  def delivery_failed(from, to, reply_to, subject, datetime, email_body)
    @from = from
    @to = to
    @datetime = datetime

    subject = t('m3.failure_mailer.delivery_failed.subject', subject: subject)
    message = mail(subject: subject, to: (reply_to.presence || from))

    part = Mail::Part.new(content_type: 'message/rfc822', body: email_body)
    message.add_part(part)
    message.content_type = message.content_type.gsub('multipart/alternative', 'multipart/mixed')
    message
  end
end
