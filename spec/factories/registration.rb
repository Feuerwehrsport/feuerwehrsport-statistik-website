FactoryBot.define do
  factory :registrations_competition, class: Registrations::Competition do
    name 'D-Cup'
    date { Date.today }
    place 'Ort'
    admin_user { AdminUser.first }
    published true
    group_score true
  end

  factory :registrations_team, class: Registrations::Team do
    competition { build(:registrations_competition) }
    name 'FF Mannschaft'
    shortcut 'Mannschaft'
    gender :male
    admin_user { AdminUser.first }
  end

  factory :registrations_person, class: Registrations::Person do
    competition { build(:registrations_competition) }
    first_name 'Alfred'
    last_name 'Meier'
    gender :male
    admin_user { AdminUser.first }
  end
end
