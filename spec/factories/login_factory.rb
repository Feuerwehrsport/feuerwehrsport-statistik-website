# frozen_string_literal: true

FactoryBot.define do
  factory :login do
    password { 'Secret123' }
    email_address { 'my_account1994@gmail.com' }
    initialize_with { Login.find_or_initialize_by(email_address:) }
    verified_at { Time.current }

    trait :not_verified do
      verified_at { nil }
    end

    trait :expired do
      expired_at { 1.hour.ago }
    end
  end
end
