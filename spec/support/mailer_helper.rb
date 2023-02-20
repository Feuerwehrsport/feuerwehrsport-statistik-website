# frozen_string_literal: true

def mailer_signature
  <<~HEREDOC

    ---------------------------------------------------------
    Diese E-Mail wurde von der Webseite
    https://feuerwehrsport-statistik.de
    gesendet. Es handelt sich um eine automatisch generierte
    E-Mail. Bei Fragen, Anregungen und Kritik nutzen Sie die
    Kontaktdaten, die im Impressum der Seite hinterlegt sind.
  HEREDOC
end

def expect_with_mailer_signature(body)
  expect(mail.attachments).to have(0).attachment
  expect(mail.body.raw_source.gsub("\r\n", "\n")).to eq(body + mailer_signature)
end

def expect_with_mailer_signature_and_attachments(attachments, body)
  expect(mail.body.parts.first.body.raw_source.gsub("\r\n", "\n")).to eq(body + mailer_signature)

  expect(mail.attachments).to have(attachments.count).attachment
  attachments.each_with_index do |a, i|
    attachment = mail.attachments[i]
    expect(attachment).to be_a_kind_of(Mail::Part)
    expect(attachment.content_type).to eq(a[:content_type])
    expect(attachment.filename).to eq(a[:filename])
  end
end
