# frozen_string_literal: true

def mailer_signature
  <<~HEREDOC

    ---------------------------------------------------------
    Diese E-Mail wurde automatisch von
    https://feuerwehrsport-statistik.de
    verschickt. Bei Fragen, Anregungen oder Kritik findest du
    die Kontaktdaten im Impressum der Website.
  HEREDOC
end

def expect_with_mailer_signature(body)
  expect(mail.attachments.count).to eq 0
  expect(mail.body.raw_source.gsub("\r\n", "\n")).to eq(body + mailer_signature)
end

def expect_with_mailer_signature_and_attachments(attachments, body)
  expect(mail.body.parts.first.body.raw_source.gsub("\r\n", "\n")).to eq(body + mailer_signature)

  expect(mail.attachments.count).to eq attachments.count
  attachments.each_with_index do |a, i|
    attachment = mail.attachments[i]
    expect(attachment).to be_a(Mail::Part)
    expect(attachment.content_type).to eq(a[:content_type])
    expect(attachment.filename).to eq(a[:filename])
  end
end
