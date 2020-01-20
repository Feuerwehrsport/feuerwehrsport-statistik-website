FactoryBot.define do
  factory :nation do
    id { 1 }
    name { 'Deutschland' }
    iso { 'de' }

    trait :ungarn do
      id { 2 }
      name { 'Ungarn' }
      iso { 'hu' }
    end
  end
end
