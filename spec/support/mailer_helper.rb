def mailer_signature
  "\n" \
    "---------------------------------------------------------\n" \
    "Diese E-Mail wurde von der Webseite\n" \
    "https://www.feuerwehrsport-statistik.de\n" \
    "gesendet. Es handelt sich um eine automatisch generierte\n" \
    "E-Mail. Bei Fragen, Anregungen und Kritik nutzen Sie die\n" \
    'Kontaktdaten, die im Impressum der Seite hinterlegt sind.'
end

def expect_with_mailer_signature(body)
  expect(mail.body.raw_source).to eq(body + mailer_signature)
end
