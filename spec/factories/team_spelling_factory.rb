# frozen_string_literal: true
FactoryBot.define do
  factory :team_spelling do
    name { 'FF Warino' }
    shortcut { 'Warino' }

    team { Team.first || build(:team) }
  end
end
