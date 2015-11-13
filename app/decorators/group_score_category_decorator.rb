class GroupScoreCategoryDecorator < ApplicationDecorator
  decorates_association :competition
  decorates_association :group_score_type

  def to_s
    name == "default" ? "Standardwertung" : name
  end

  def shortcut(options={})
    name == "default" ? "" : "#{options[:prefix]}#{name}"
  end
end
