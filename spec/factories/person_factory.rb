# frozen_string_literal: true
FactoryBot.define do
  factory :person do
    first_name { 'Alfred' }
    last_name { 'Meier' }
    gender { :male }
    nation { Nation.first || build(:nation) }

    trait :female do
      first_name { 'Johanna' }
      last_name { 'Meyer' }
      gender { :female }
    end

    trait :with_best_scores do
      best_scores { { 'pb' => { 'hb' => [2324, 'Name des Wettkampfes'], 'hl' => nil } } }
    end
  end
end
