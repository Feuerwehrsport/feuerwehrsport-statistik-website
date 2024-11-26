# frozen_string_literal: true

class Series::Participation < ApplicationRecord
  include Firesport::TimeInvalid

  belongs_to :cup, class_name: 'Series::Cup'
  belongs_to :assessment, class_name: 'Series::Assessment'

  validates :time, :points, :rank, presence: true
  schema_validations
end
