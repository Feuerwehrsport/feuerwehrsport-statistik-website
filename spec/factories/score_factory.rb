# frozen_string_literal: true

FactoryBot.define do
  factory :score do
    person { Person.first || build(:person) }
    team { Team.first || build(:team) }
    team_number { 1 }
    time { 1976 }
    single_discipline factory: %i[single_discipline hb_male]
    competition { Competition.first || build(:competition) }

    trait :double do
      after(:create) do |score|
        create(:score, time: 2091, person: score.person, team: score.team, competition: score.competition,
                       single_discipline: score.single_discipline)
      end
    end

    trait :hl do
      single_discipline factory: %i[single_discipline hl_male]
    end

    trait :hb do
      single_discipline factory: %i[single_discipline hb_male]
    end
  end
end
