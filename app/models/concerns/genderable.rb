module Genderable
  GENDERS = { female: 0, male: 1 }
  extend ActiveSupport::Concern
  included do
    enum gender: GENDERS
    scope :gender, -> (gender) { where(gender: GENDERS[gender.to_sym]) }
  end
end