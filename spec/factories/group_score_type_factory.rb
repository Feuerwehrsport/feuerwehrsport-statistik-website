# frozen_string_literal: true

FactoryBot.define do
  factory :group_score_type do
    discipline { 'la' }
    name { 'WKO' }
    sequence(:key) { |n| "typ_#{n}" }
    regular { true }
  end
end
