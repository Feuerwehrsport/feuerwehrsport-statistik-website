class ChangeLog < ActiveRecord::Base
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

  validates :model_class, :action_name, :content, presence: true

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
    if user.is_a?(APIUser)
      self.api_user = user
    elsif user.is_a?(AdminUser)
      self.admin_user = user
    end
  end

  %i[after before].each do |type|
    define_method("build_#{type}_model") do
      object = model_class.constantize.new
      content[:"#{type}_hash"].each do |attribute, value|
        begin
          object.send(:"#{attribute}=", value) if object.respond_to?(:"#{attribute}=")
        rescue ActiveRecord::AssociationTypeMismatch
        end
      end
      object
    end
  end
end
