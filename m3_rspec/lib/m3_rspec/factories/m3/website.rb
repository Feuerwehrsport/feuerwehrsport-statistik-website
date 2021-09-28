# frozen_string_literal: true

FactoryBot.define do
  factory :m3_website, class: 'M3::Website' do
    name { 'Kranbauer Webpräsenz' }
    domain { 'www.kranbauer.de' }
    key { Rails.configuration.m3_rspec.website_key || :kranbauer }
    title { 'Kranbauen-Kräne sind Norddeutschlands höchsten Kräne' }
    initialize_with { M3::Website.find_or_initialize_by(name: name) }

    after(:build) do |website|
      website.delivery_setting = build(:m3_delivery_setting, website: website)
    end
  end
end
