# frozen_string_literal: true

class ChangeLog < ApplicationRecord
  FREE_ACCESS_CLASSES = %w[
    Appointment
    Competition
    Event
    Link
    Nation
    News
    Person
    Place
    Team
  ].freeze

  belongs_to :admin_user
  belongs_to :api_user

  scope :free_access, -> { where(model_class: FREE_ACCESS_CLASSES) }

  def content
    (super || {}).deep_symbolize_keys
  end

  def before_hash=(hash)
    set(:before_hash, hash)
  end

  def after_hash=(hash)
    set(:after_hash, hash)
  end

  def set(key, value)
    content_hash = content
    content_hash[key] = value
    self.content = content_hash
  end

  def user=(user)
    case user
    when APIUser
      self.api_user = user
    when AdminUser
      self.admin_user = user
    end
  end

  %i[after before].each do |type|
    define_method("build_#{type}_model") do
      object = model_class.constantize.new
      content[:"#{type}_hash"].each do |attribute, value|
        object.send(:"#{attribute}=", value) if object.respond_to?(:"#{attribute}=")
      rescue ActiveRecord::AssociationTypeMismatch => e
        Rails.logger.debug { "Mismatch: #{e.message}" }
      end
      object
    end
  end
end
