class GroupScoreCategoryDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :competition, :name, :group_score_type, :discipline

  decorates_association :competition
  decorates_association :group_score_type

  def to_s
    name == "default" ? "Standardwertung" : name
  end

  def with_competition
    "#{to_s} - #{competition}"
  end

  def discipline
    group_score_type.discipline
  end

  def shortcut(options={})
    name == "default" ? "" : "#{options[:prefix]}#{name}"
  end
end
