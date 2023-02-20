# frozen_string_literal: true
FactoryBot.define do
  factory :series_cup, class: 'Series::Cup' do
    round { Series::Round.first || build(:series_round) }
    competition { Competition.first || build(:competition) }
  end
end
