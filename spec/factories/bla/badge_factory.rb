# frozen_string_literal: true

FactoryBot.define do
  factory :bla_badge, class: 'Bla::Badge' do
    person { Person.first || build(:person) }
    hl_score { person.scores.hl.first || build(:score, :hl, person:) }
    hb_score { person.scores.hb.first || build(:score, :hb, person:) }
    year { 2017 }
    status { :silver }
  end
end
