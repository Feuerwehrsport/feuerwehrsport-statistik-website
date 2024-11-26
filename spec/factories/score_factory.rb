# frozen_string_literal: true

FactoryBot.define do
  factory :score do
    person { Person.first || build(:person) }
    team { Team.first || build(:team) }
    team_number { 1 }
    time { 1976 }
    discipline { 'hb' }
    single_discipline { build(:single_discipline, :hb_male) }
    competition { Competition.first || build(:competition) }

    trait :double do
      after(:create) do |score|
        create(:score, time: 2091, person: score.person, team: score.team, competition: score.competition,
                       discipline: score.discipline)
      end
    end

    trait :hl do
      discipline { :hl }
      single_discipline { build(:single_discipline, :hl_male) }
    end

    trait :hb do
      discipline { :hb }
      single_discipline { build(:single_discipline, :hb_male) }
    end

    trait :hw do
      discipline { :hw }
      single_discipline { build(:single_discipline, :hb_female) }
    end
  end
end
