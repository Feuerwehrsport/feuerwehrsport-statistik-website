# frozen_string_literal: true

FactoryBot.define do
  factory :news_article do
    title { 'Neuigkeiten von heute' }
    content { 'Inhalt' }
    admin_user { AdminUser.first || build(:admin_user) }
    published_at { Date.parse('2017-01-01') }
  end
end
