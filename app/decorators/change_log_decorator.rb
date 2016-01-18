class ChangeLogDecorator < ApplicationDecorator
  decorates_association :admin_user
  decorates_association :api_user

  def diff_hash
    before_hash = object.content[:before_hash] || {}
    after_hash = object.content[:after_hash] || {}
    before_hash.deep_diff(after_hash)
  end

  def translated_action
    "#{object.model_class} #{object.log_action || object.action_name}"
  end

  def user_name
    admin_user || "API-Benutzer"
  end
end
