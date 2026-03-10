# frozen_string_literal: true

FactoryBot.define do
  factory :series_person_participation, class: 'Series::PersonParticipation' do
    person_assessment { Series::PersonAssessment.first || build(:series_person_assessment) }
    cup { Series::Cup.first || build(:series_cup) }
    person { Person.first || build(:person) }
    time { 1899 }
    points { 15 }
    rank { 2 }
  end

  factory :series_team_participation, class: 'Series::TeamParticipation' do
    team_assessment { Series::TeamAssessment.first || build(:series_team_assessment) }
    cup { Series::Cup.first || build(:series_cup) }
    team { Team.first || build(:team) }
    team_number { 1 }
    team_gender { 1 }
    time { 1899 }
    points { 15 }
    rank { 2 }
  end
end
