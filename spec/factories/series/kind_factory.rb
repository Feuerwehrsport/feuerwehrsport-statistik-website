# frozen_string_literal: true

FactoryBot.define do
  factory :series_kind, class: 'Series::Kind' do
    name { 'D-Cup' }
    slug { 'd-cup' }
  end
end
