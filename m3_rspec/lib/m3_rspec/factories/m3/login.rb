# frozen_string_literal: true

FactoryBot.define do
  factory :m3_login, class: 'M3::Login::Base' do
    website { M3::Website.first || build(:m3_website) }
    password { 'Secret123' }
    password_digest { '$2a$10$ZXjJBwkQ9aFZwBUEpLDBaOUkZsocc3w7N0/B2/UDZ6pWCI2UfAm7a' }
    email_address { 'my_account1994@gmail.com' }
    initialize_with { M3::Login::Base.find_or_initialize_by(email_address: email_address) }
    verified_at { Time.current }
    verify_token { @instance.email_address.presence&.parameterize&.underscore }
    password_reset_token { @instance.email_address.presence&.parameterize&.underscore }
    changed_email_address_token { @instance.email_address.presence&.parameterize&.underscore }

    trait :not_verified do
      verified_at { nil }
    end

    trait :expired do
      expired_at { 1.hour.ago }
    end

    trait :with_password_reset_token do
      password_reset_requested_at { 1.minute.ago }
    end
  end
end
