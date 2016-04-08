require "rails_helper"

RSpec.describe CompReg::CompetitionMailer, type: :mailer do
  let(:team) { create(:comp_reg_team) }
  let(:person) { create(:comp_reg_person) }

  describe '#new_team_registered' do
    let(:mail) { described_class.new_team_registered(team) }

    it 'renders the header information' do
      expect(mail.subject).to eq "Neue Wettkampfanmeldung für D-Cup - 08.04.2016"
      expect(mail.to).to eq(["user@first.com"])
      expect(mail.from).to eq(["automailer@feuerwehrsport-statistik.de"])
    end

    it 'assigns body' do
      expect(mail.body.raw_source).to eq(
        "Es wurde eine neue Mannschaft für den Wettkampf D-Cup - 08.04.2016 angemeldet.\n" +
        "\n" +
        "Weitere Informationen zu deinem Wettkampf findest du hier:\n" +
        "http://localhost/comp_reg/competitions/#{team.competition.id}\n" +
        "\n" +
        "Mannschaft: FF Mannschaft 1\n" +
        "Geschlecht: männlich\n" +
        "Absender: Test-user-first\n" +
        "\n" +
        "Bitte beachte, dass du über weitere Änderungen bezüglich dieser Mannschaft nicht separat informiert wirst.\n" +
        mailer_signature
      )
    end
  end

  describe '#new_person_registered' do
    let(:mail) { described_class.new_person_registered(person) }

    it 'renders the header information' do
      expect(mail.subject).to eq "Neue Wettkampfanmeldung für D-Cup - 08.04.2016"
      expect(mail.to).to eq(["user@first.com"])
      expect(mail.from).to eq(["automailer@feuerwehrsport-statistik.de"])
    end

    it 'assigns body' do
      expect(mail.body.raw_source).to eq(
        "Es wurde ein neuer Einzelstarter für den Wettkampf D-Cup - 08.04.2016 angemeldet.\n" +
        "\n" +
        "Weitere Informationen zu deinem Wettkampf findest du hier:\n" +
        "http://localhost/comp_reg/competitions/#{person.competition.id}\n" +
        "\n" +
        "Wettkämpfer: Alfred Meier\n" +
        "Geschlecht: männlich\n" +
        "Absender: Test-user-first\n" +
        "\n" +
        "Bitte beachte, dass du über weitere Änderungen bezüglich dieses Einzelstarters nicht separat informiert wirst.\n" +
        mailer_signature
      )
    end
  end
end