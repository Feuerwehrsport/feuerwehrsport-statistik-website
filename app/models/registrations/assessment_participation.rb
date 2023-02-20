# frozen_string_literal: true
class Registrations::AssessmentParticipation < ApplicationRecord
  belongs_to :assessment, class_name: 'Registrations::Assessment'

  validates :assessment, presence: true
end
