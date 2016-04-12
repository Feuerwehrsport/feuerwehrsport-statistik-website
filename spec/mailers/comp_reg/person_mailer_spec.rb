require "rails_helper"

RSpec.describe CompReg::PersonMailer, type: :mailer do
  let(:person) { create(:comp_reg_person) }
  before { Timecop.freeze(Time.parse("2016-04-08")) }
  after { Timecop.return }

  describe '#notification_to_creator' do
    let(:mail) { described_class.notification_to_creator(person) }

    it 'renders the header information' do
      expect(mail.subject).to eq "Deine Wettkampfanmeldung für D-Cup - 08.04.2016"
      expect(mail.to).to eq(["user@first.com"])
      expect(mail.from).to eq(["automailer@feuerwehrsport-statistik.de"])
    end

    it 'assigns body' do
      expect(mail.body.raw_source).to eq(
        "Du hast einen Einzelstarter für den Wettkampf D-Cup - 08.04.2016 angemeldet.\n" +
        "\n" +
        "Weitere Informationen zu diesem Wettkampf findest du hier:\n" +
        "http://localhost/comp_reg/competitions/#{person.competition.id}\n" +
        "\n" +
        "Du kannst deine Anmeldung auch weiterhin bearbeiten oder wieder entfernen. Nutze dafür die folgende Seite:\n" +
        "http://localhost/comp_reg/people/#{person.id}/edit\n" +
        "\n" +
        "Wettkämpfer: Alfred Meier\n" +
        "Geschlecht: männlich\n" +
        mailer_signature
      )
    end
  end
end