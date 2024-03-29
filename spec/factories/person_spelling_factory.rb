# frozen_string_literal: true

FactoryBot.define do
  factory :person_spelling do
    first_name { 'Alfredo' }
    last_name { 'Mayer' }
    gender { :male }

    person { Person.first || build(:person) }
  end
end
