FactoryBot.define do
  factory :admin_user do
    role :user
    login { build(:m3_login, email_address: 'admin_user@example.com', name: 'admin user') }

    trait :user do
      role :user
    end

    trait :admin do
      role :admin
    end

    trait :sub_admin do
      role :sub_admin
    end
  end
end
