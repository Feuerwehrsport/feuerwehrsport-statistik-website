# frozen_string_literal: true

FactoryBot.define do
  factory :score do
    person { Person.first || build(:person) }
    team { Team.first || build(:team) }
    team_number { 1 }
    time { 1976 }
    discipline { 'hb' }
    competition { Competition.first || build(:competition) }

    trait :double do
      after(:create) do |score|
        create(:score, time: 2091, person: score.person, team: score.team, competition: score.competition,
                       discipline: score.discipline)
      end
    end

    trait :hl do
      discipline { :hl }
    end

    trait :hb do
      discipline { :hb }
    end

    trait :hw do
      discipline { :hw }
    end
  end
end
