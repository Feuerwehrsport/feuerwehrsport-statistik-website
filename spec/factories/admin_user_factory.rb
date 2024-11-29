# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    role { :user }
    login factory: :m3_login, email_address: 'admin_user@example.com', name: 'admin user'

    trait :user do
      role { :user }
      login factory: :m3_login, email_address: 'user@example.com', name: 'user'
    end

    trait :admin do
      role { :admin }
      login factory: :m3_login, email_address: 'admin@example.com', name: 'admin'
    end

    trait :sub_admin do
      role { :sub_admin }
      login factory: :m3_login, email_address: 'sub_admin@example.com', name: 'sub_admin'
    end
  end
end
