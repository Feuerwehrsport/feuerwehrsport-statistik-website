# frozen_string_literal: true

class Registrations::Band < ApplicationRecord
  GENDER_KEYS = %i[female male indifferent].freeze
  GENDERS = { female: 0, male: 1, indifferent: 2 }.freeze

  enum gender: GENDERS
  default_scope { order(:position) }
  scope :gender, ->(gender) { where(gender: GENDERS[gender.to_sym]) }

  belongs_to :competition, class_name: 'Registrations::Competition'
  has_many :assessments, class_name: 'Registrations::Assessment', dependent: :destroy
  has_many :teams, class_name: 'Registrations::Team', dependent: :destroy
  has_many :people, class_name: 'Registrations::Person', dependent: :destroy

  acts_as_list scope: :competition

  def person_tag_list
    person_tags.split(',').each(&:strip!)
  end

  def team_tag_list
    team_tags.split(',').each(&:strip!)
  end
end
