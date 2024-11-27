# frozen_string_literal: true

class SingleDiscipline < ApplicationRecord
  has_many :scores, dependent: :restrict_with_exception
  schema_validations

  def self.g(id)
    @single_disciplines ||= {}
    @single_disciplines[id] || load_all[id] || raise(ActiveRecord::RecordNotFound)
  end

  def self.gall
    @single_disciplines&.values || load_all&.values
  end

  def self.load_all
    @single_disciplines = {}
    reorder(:id).each { |sd| @single_disciplines[sd.id] = sd }
    @single_disciplines
  end
end
