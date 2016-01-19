class ChangeRequestDecorator < ApplicationDecorator
  decorates_association :admin_user
  decorates_association :api_user
  decorates_association :user
end
