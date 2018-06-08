FactoryBot.define do
  factory :api_user do
    name 'Api User'
    email_address 'api@user.de'
    ip_address_hash '1234'
    user_agent_hash '1234'
  end
end
