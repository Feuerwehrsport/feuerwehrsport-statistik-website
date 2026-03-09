# frozen_string_literal: true

class Series::PersonParticipation < ApplicationRecord
  include Firesport::TimeInvalid

  belongs_to :cup, class_name: 'Series::Cup'
  belongs_to :person_assessment, class_name: 'Series::PersonAssessment'
  belongs_to :person, class_name: '::Person'

  schema_validations
end
