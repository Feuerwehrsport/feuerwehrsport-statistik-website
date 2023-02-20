# frozen_string_literal: true

FactoryBot.define do
  factory :person_participation do
    person { Person.first || build(:person) }
    group_score { GroupScore.first || build(:group_score) }
    position { 3 }
  end
end
