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

  def self.default_for(key, gender, year)
    for_keys = gall.select { |sd| sd.key == key.to_s }
    if gender == :male
      for_keys.find(&:default_for_male?)
    elsif key == :hb && year.try(:<, 2017)
      for_keys.find { |sd| sd.id == 5 }
    else
      for_keys.find(&:default_for_female?)
    end
  end

  def self.group_assessment_ids(key, gender)
    if key == :hl
      [gender == :male ? 1 : 2]
    elsif key == :hb
      gender == :male ? [3] : [4, 5]
    end
  end
end
