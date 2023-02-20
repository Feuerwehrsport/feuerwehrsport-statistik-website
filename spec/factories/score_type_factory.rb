# frozen_string_literal: true
FactoryBot.define do
  factory :score_type do
    people { 10 }
    run { 8 }
    score { 6 }
  end
end
