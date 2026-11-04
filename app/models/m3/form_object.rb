# frozen_string_literal: true

module M3::FormObject
  extend ActiveSupport::Concern

  included do
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ActiveRecord::AttributeAssignment
    include ActiveRecord::Callbacks
    include Draper::Decoratable
    include M3::FormObjectAssociations

    define_model_callbacks :initialize, only: :after
  end

  class_methods do
    def find(*args); end
  end

  def initialize(*args)
    super
    run_callbacks :initialize
  end

  def persisted?
    false
  end

  def new_record?
    !persisted?
  end

  def save
    false
  end

  def destroy
    false
  end
end
