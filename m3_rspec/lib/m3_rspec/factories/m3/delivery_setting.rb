# frozen_string_literal: true

FactoryBot.define do
  factory :m3_delivery_setting, class: 'M3::DeliverySetting' do
    website { build(:m3_website) }
    delivery_method { :test }
    from_address { 'info@kranbauer.de' }
    from_name { 'Kranbauer' }
  end
end
