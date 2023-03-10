# frozen_string_literal: true

class Series::Kind < ApplicationRecord
  has_many :rounds, class_name: 'Series::Round', dependent: :restrict_with_exception

  def disciplines
    rounds.map(&:disciplines).flatten.uniq
  end
end
