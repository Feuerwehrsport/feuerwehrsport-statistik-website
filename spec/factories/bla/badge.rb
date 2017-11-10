FactoryBot.define do
  factory :bla_badge, class: BLA::Badge do
    person { Person.first || build(:person) }
    hl_score { person.scores.hl.first || build(:score, :hl, person: person) }
    hb_score { person.scores.hb.first || build(:score, :hb, person: person) }
    year 2017
    status :silver
  end
end
