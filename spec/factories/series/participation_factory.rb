FactoryBot.define do
  factory :series_person_participation, class: 'Series::PersonParticipation' do
    assessment { Series::PersonAssessment.first || build(:series_person_assessment) }
    cup { Series::Cup.first || build(:series_cup) }
    person { Person.first || build(:person) }
    time { 1899 }
    points { 15 }
    rank { 2 }
  end
end
