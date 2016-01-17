class ChangeLog < ActiveRecord::Base
  belongs_to :admin_user
  belongs_to :api_user

  def content
    (super || {}).deep_symbolize_keys
  end

  def before_hash=(hash)
    set(:before_hash, hash)
  end

  def after_hash=(hash)
    set(:after_hash, hash)
  end

  def model_class=(model_class)
    set(:model_class, model_class.to_s)
  end

  def action_name=(action_name)
    set(:action_name, action_name)
  end

  def set(key, value)
    content_hash = content
    content_hash[key] = value
    self.content = content_hash
  end

  def user=(user)
    if user.is_a?(APIUser)
      self.api_user = user
    elsif user.is_a?(AdminUser)
      self.admin_user = user
    end
  end
end
