# frozen_string_literal: true

FactoryBot.define do
  factory :registrations_competition, class: 'Registrations::Competition' do
    name { 'D-Cup' }
    date { Time.zone.today }
    place { 'Ort' }
    admin_user { AdminUser.first || build(:admin_user) }
    published { true }
    group_score { true }
  end

  factory :registrations_band, class: 'Registrations::Band' do
    competition { build(:registrations_competition) }
    name { 'Männer' }
    gender { :male }
  end

  factory :registrations_team, class: 'Registrations::Team' do
    band { build(:registrations_band) }
    name { 'FF Mannschaft' }
    shortcut { 'Mannschaft' }
    admin_user { AdminUser.first || build(:admin_user) }
  end

  factory :registrations_person, class: 'Registrations::Person' do
    band { build(:registrations_band) }
    first_name { 'Alfred' }
    last_name { 'Meier' }
    admin_user { AdminUser.first || build(:admin_user) }
  end

  factory :registrations_assessment, class: 'Registrations::Assessment' do
    band { build(:registrations_band) }
    discipline { 'hl' }

    trait :la do
      discipline { 'la' }
    end
  end
end
