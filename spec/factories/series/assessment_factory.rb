# frozen_string_literal: true

FactoryBot.define do
  factory :series_person_assessment, class: 'Series::PersonAssessment' do
    round { Series::Round.first || build(:series_round) }
    discipline { 'hl' }
    gender { 'male' }
    name { '' }

    factory :series_team_assessment, class: 'Series::TeamAssessment' do
      discipline { 'la' }
      gender { 'female' }
    end
  end
end
