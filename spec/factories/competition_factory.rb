FactoryBot.define do
  factory :competition do
    event { Event.first || build(:event) }
    place { Place.first || build(:place) }
    name { 'Erster Lauf' }
    date { Date.parse('2017-05-01') }

    trait :score_type do
      score_type { ScoreType.first || create(:score_type) }
    end
    trait :fake_count do
      hl_female { 10 }
      hl_male { 11 }
      hb_female { 12 }
      hb_male { 13 }
      gs { 14 }
      fs_female { 15 }
      fs_male { 16 }
      la_female { 17 }
      la_male { 18 }
      teams_count { 19 }
      people_count { 20 }
    end
  end
end
