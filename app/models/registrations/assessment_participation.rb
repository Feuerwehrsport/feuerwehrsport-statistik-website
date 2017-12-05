class Registrations::AssessmentParticipation < ActiveRecord::Base
  belongs_to :assessment, class_name: 'Registrations::Assessment'

  validates :assessment, presence: true
end
