FactoryBot.define do
  factory :series_round, class: Series::Round do
    name 'D-Cup'
    slug 'd-cup'
    year 2016
    aggregate_type 'DCup'
  end
end
