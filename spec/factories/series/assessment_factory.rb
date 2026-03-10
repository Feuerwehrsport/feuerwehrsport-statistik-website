# frozen_string_literal: true

FactoryBot.define do
  factory :series_person_assessment, class: 'Series::PersonAssessment' do
    round { Series::Round.first || build(:series_round) }
    discipline { 'hl' }
    key { 'female' }
  end

  factory :series_team_assessment, class: 'Series::TeamAssessment' do
    round { Series::Round.first || build(:series_round) }
    discipline { 'la' }
    key { 'female' }
  end
end
