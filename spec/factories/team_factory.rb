# frozen_string_literal: true
FactoryBot.define do
  factory :team do
    name { 'FF Warin' }
    shortcut { 'Warin' }
    status { :fire_station }
    latitude { '52.12' }
    longitude { '14.45' }
    state { 'MV' }

    trait :mv do
      name { 'Team Mecklenburg-Vorpommern' }
      shortcut { 'Team MV' }
      status { :team }
    end

    trait :without_geo_location do
      latitude { nil }
      longitude { nil }
    end
  end
end
