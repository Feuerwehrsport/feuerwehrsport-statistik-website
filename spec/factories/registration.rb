FactoryBot.define do
  factory :registrations_competition, class: 'Registrations::Competition' do
    name { 'D-Cup' }
    date { Time.zone.today }
    place { 'Ort' }
    admin_user { AdminUser.first || build(:admin_user) }
    published { true }
    group_score { true }
  end

  factory :registrations_team, class: 'Registrations::Team' do
    competition { build(:registrations_competition) }
    name { 'FF Mannschaft' }
    shortcut { 'Mannschaft' }
    gender { :male }
    admin_user { AdminUser.first || build(:admin_user) }
  end

  factory :registrations_person, class: 'Registrations::Person' do
    competition { build(:registrations_competition) }
    first_name { 'Alfred' }
    last_name { 'Meier' }
    gender { :male }
    admin_user { AdminUser.first || build(:admin_user) }
  end

  factory :registrations_assessment, class: 'Registrations::Assessment' do
    competition { build(:registrations_competition) }
    discipline { 'hl' }
    gender { :male }

    trait :la do
      discipline { 'la' }
    end
  end
end
