# frozen_string_literal: true

FactoryBot.define do
  factory :series_round, class: 'Series::Round' do
    kind { Series::Kind.first || build(:series_kind) }
    year { 2016 }
    aggregate_type { 'DCup' }
  end
end
