# frozen_string_literal: true

class ChangeRequestDecorator < AppDecorator
  decorates_association :admin_user
  decorates_association :api_user
  decorates_association :user
end
