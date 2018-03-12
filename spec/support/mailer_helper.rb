def mailer_signature
  "\n" \
    "---------------------------------------------------------\n" \
    "Diese E-Mail wurde von der Webseite\n" \
    "https://feuerwehrsport-statistik.de\n" \
    "gesendet. Es handelt sich um eine automatisch generierte\n" \
    "E-Mail. Bei Fragen, Anregungen und Kritik nutzen Sie die\n" \
    'Kontaktdaten, die im Impressum der Seite hinterlegt sind.'
end

def expect_with_mailer_signature(body)
  expect(mail.attachments).to have(0).attachment
  expect(mail.body.raw_source).to eq(body + mailer_signature)
end

def expect_with_mailer_signature_and_attachments(body, attachments)
  expect(mail.body.parts.first.body.raw_source).to eq(body + mailer_signature)

  expect(mail.attachments).to have(attachments.count).attachment
  attachments.each_with_index do |a, i|
    attachment = mail.attachments[i]
    expect(attachment).to be_a_kind_of(Mail::Part)
    expect(attachment.content_type).to eq(a[:content_type])
    expect(attachment.filename).to eq(a[:filename])
  end
end
