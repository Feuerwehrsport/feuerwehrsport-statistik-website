# frozen_string_literal: true

class Calc::Base
  include ActiveModel::Model
  delegate :t, to: I18n
  attr_accessor :view_context
end
